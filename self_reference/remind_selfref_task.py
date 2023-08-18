#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import pandas as pd
import random
import os  # handy system and path functions
import csv
import time
from pull_timings import *
from bids_tsv_convert_function import *
# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# which buttons on the button box correspond to left & right choices (DIAMOND 4-button)
# YES=LEFT, NO=RIGHT
yes_button_number='3'
no_button_number='1'

# Store info about the experiment session
expName = 'task-selfref' 

# Make sure user fills out session field of dialog box
expInfo = {'participant':'', 'session':['', 'loc', 'nf'], 'run':1, 'friend_name':''}
while expInfo['session'] not in ['loc', 'nf'] or expInfo['run'] not in ['1','2']:
    expInfo['session'] = ['', 'loc', 'nf']
    expInfo['run'] = ['', '1', '2']
    dlg = gui.DlgFromDict(dictionary=expInfo, title=expName,
        labels = {'participant': 'Participant ID (remind####)', 
                  'run': 'Run (1 or 2)', 
                  'session': 'Session',
                  'friend_name': 'Friend Name'},
                  order = ['participant', 'session', 'run', 'friend_name'])
    if dlg.OK == False: 
        core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
expInfo['participant'] = f"sub-{expInfo['participant']}" 

if not os.path.exists(f'{_thisDir}/data/'):
    os.mkdir(f'{_thisDir}/data/')

if not os.path.exists(f"{_thisDir}/data/{expInfo['participant']}"):
    os.mkdir(f"{_thisDir}/data/{expInfo['participant']}")

# pull word order for the participant
# remove string from participant ID to get just the #
participant_number = int(expInfo['participant'].replace('sub-remind', '')[-3:])
print(participant_number)

# pull corresponding file
word_order_file = f"word_list_splits/word_order_{participant_number}.csv"
word_order = pd.read_csv(word_order_file)

# internal run numbers 1-4 based on session (loc vs. nf) and run within session (1 vs. 2)
if int(expInfo['run']) == 1:
    if expInfo['session'] == 'loc':
        run_num = 1
    elif expInfo['session'] == 'nf':
        run_num = 3
if int(expInfo['run']) == 2:
    if expInfo['session'] == 'loc':
        run_num = 2
    elif expInfo['session'] == 'nf':
        run_num = 4

# Pull words specifically for this run & split into positive/negative lists
word_list = word_order[word_order.run == run_num]
negative_words = list(word_list.word[word_list.valence_condition == '-'])
positive_words = list(word_list.word[word_list.valence_condition == '+']) 

# Shuffle the order of positive/negative word lists within the run
random.shuffle(positive_words)
random.shuffle(negative_words)

# for practice in very first run
practice_words = ['quiet', 'loud', 'cautious', 'wild', 'ordinary', 'precise']

# Counterbalence ISI orders
if participant_number % 4 in [0,1]:
    timing_templates = ['0005', '0014', '0067', '0072']
elif participant_number % 4 in [2,3]:
    timing_templates = ['0072', '0067', '0014', '0005']

# load timings for positive & negative word depending on run
pos = np.loadtxt(f"stim_timing_template_files/stimes_pos_{timing_templates[run_num-1]}.1D")
neg = np.loadtxt(f"stim_timing_template_files/stimes_neg_{timing_templates[run_num-1]}.1D")


# Counterbalance block orders
block_order1=['self', 'other',  'other', 'semantic', 'self',  'other', 'semantic', 'self',  'self', 'other']
block_order2=['other', 'self',  'self', 'semantic', 'other',  'self', 'semantic', 'other',  'other', 'self']
block_order3=['other', 'self', 'semantic',  'self', 'other',  'self', 'other',  'semantic', 'other','self']
block_order4=['self', 'other', 'semantic',  'other', 'self',  'other', 'self',  'semantic', 'self','other']

if participant_number % 3 ==0:
    if run_num==1:
      cur_block_order = block_order1
    elif run_num==2:
      cur_block_order = block_order2
    elif run_num==3:
      cur_block_order = block_order3
    elif run_num==4:
      cur_block_order = block_order4
elif participant_number % 3 == 1:
    if run_num==1:
      cur_block_order = block_order4
    elif run_num==2:
      cur_block_order = block_order3
    elif run_num==3:
      cur_block_order = block_order2
    elif run_num==4:
      cur_block_order = block_order1
elif participant_number % 3 ==2:
    if run_num==1:
      cur_block_order = block_order2
    elif run_num==2:
      cur_block_order = block_order1
    elif run_num==3:
      cur_block_order = block_order4
    elif run_num==4:
      cur_block_order = block_order3

block_order = pd.DataFrame({'block': np.arange(10), 
    'block_type': cur_block_order})

all_block_timings = make_run_timings(pos = pos, neg = neg)
print(all_block_timings)


# output file stem
filename = f"{_thisDir}/data/{expInfo['participant']}/{expInfo['participant']}_ses-{expInfo['session']}_task-selfref_run-{expInfo['run']}"

# Function to write a line of data to the output file
def write_to_tsv(row_info:list):
    with open(filename+'_events.csv', 'a') as csvfile:
        stim_writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        stim_writer.writerow(row_info)
 
# Header column (following this, very important to make sure rows are written matching this column order)
write_to_tsv(['participant','session', 'date', 'exp_name', 'frame_rate', 'absolute_time', 'trigger_time', 'trial_type', 'trial_num', 'word', 'response_time','reponse_key', 'response_endorse', 'condition', 'word_valence', 'block_number'])

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)
trial_duration = 2.5
block_intro_time = 2

# Setup the Window
win = visual.Window(size=(1920, 1080), fullscr=True, screen=1, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[-1,-1,-1], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )

# Initialize components for Routine "instruct"
instructClock = core.Clock()
instruct_text = visual.TextStim(win=win, ori=0, name='instruct_text',
    text=u"Welcome!\n\nDuring this task you'll answer a series of YES or NO questions.\
\n\nYou'll have a chance to answer 3 different types of questions.", font='Arial',
    pos=[0.0, 0], height=0.08, wrapWidth=1.5,
    color='white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "trigger"
triggerClock = core.Clock()
trial_clock = core.Clock()
trigger_text = visual.TextStim(win=win, ori=0, name='trigger_text',
    text=u'waiting for scanner to begin...',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=2,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "fixation"
fixationClock = core.Clock()

fix_stim = visual.TextStim(win=win, ori=0, name='fix_stim',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


controlClock = core.Clock()
prefix = visual.TextStim(win=win, ori=0, name='prefix',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


word = visual.TextStim(win=win, ori=0, name='word',
    text='default text',    font=u'Arial',
    pos=[0, -0.2], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

yes = visual.TextStim(win=win, ori=0, name='word',
    text='YES',    font=u'Arial',
    pos=[-0.7, -.8], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

no = visual.TextStim(win=win, ori=0, name='word',
    text='NO',    font=u'Arial',
    pos=[0.7, -.8], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)
    

block_type_text = visual.TextStim(win=win, ori=0, name='word',
    text='block_text',    font=u'Arial',
    pos=[0.0, 0.2], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

postfix = visual.TextStim(win=win, ori=0, name='postfix',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-2.0)


# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

def run_instructions():
    instruct_text.draw()
    win.flip()
    wait_for_keypress(['space'])
    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), '', 'instructions', '', '', '', '','', '', '', ''])


def wait_for_keypress(key_list:list):
    continueRoutine = True
    while continueRoutine:
        theseKeys = event.getKeys(keyList=key_list)
        if len(theseKeys) > 0:  # at least one key was pressed
                # a response ends the routine
                continueRoutine = False


'''
Get trigger
'''
def get_trigger():
    #trigger_resp = event.BuilderKeyResponse()
    #trigger_resp = NOT_STARTED
    event.clearEvents(eventType='keyboard')
    trigger_text.draw()
    win.flip()
    triggerClock.reset()
    continueRoutine = True
    while continueRoutine:
        theseKeys = event.getKeys(keyList=['t', '5', 5])
        if len(theseKeys) > 0:  # at least one key was pressed
                trigger_rt = triggerClock.getTime()
                triggerClock.reset()
                print(trigger_rt)
                # a response ends the routine
                continueRoutine = False
                write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), 0, 'trigger', '', '', '','', '', '', '', ''])

'''
Run a block of trials
'''
def run_block(n_trials, block_type, block_number, practice=False):
    if block_type == 'semantic':
        block_type_text.setText(f'Is the word positive?')
    elif block_type == 'self':
        block_type_text.setText(f'Does this word describe you?')
    elif block_type == 'other':
        block_type_text.setText(f'Does this word describe {expInfo["friend_name"]}?')
    block_type_text.height = 0.2    
    block_type_text.draw()
    win.flip()
    
    # Show questions for longer during practice
    if not practice:
        write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
            expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'block_type_instruction', '', 
            '', '', '', '', block_type, '', block_number])
        core.wait(block_intro_time)

    elif practice:
        core.wait(4)
    if block_type == 'semantic':
        block_type_text.setText(f'Is this word positive?')
    elif block_type == 'self':
        block_type_text.setText(f'Are you?')
    elif block_type == 'other':
        block_type_text.setText(f'Is {expInfo["friend_name"]}?')
    block_type_text.height = 0.2
    if not practice:
        # get timings just for the current block
        block_timing_frame = all_block_timings[all_block_timings.block == block_number]
        block_timing_frame.reset_index(inplace = True)
        write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
            expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'block_start', '', 
            '', '', '', '', block_type, '', block_number])

        # run each trial in the block, pulling the word type (positive vs. negative) and fixation duration (ISI) from the block_timing_frame
        for trial_num in range(n_trials):
            run_trial(trial_type = block_timing_frame.stim_type[trial_num], 
                      fixation_duration= block_timing_frame.fix_duration[trial_num],
                      practice=False, block_type=block_type, block_number=block_number,
                      trial_num=trial_num)

'''
Show a fixation cross 
'''
def run_fixation(duration):
    # present fixation
    fix_stim.draw()
    win.flip()
    # record info to outfile
    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'fixation', '', '', '', '','', '', '', ''])
    fix_time = core.StaticPeriod(screenHz=expInfo['frameRate'])
    fix_time.start(duration) 
    fix_time.complete() 
    event.clearEvents(eventType='keyboard')

'''
Run a single trial
'''
def run_trial(trial_type, fixation_duration, practice=False, block_type='', block_number='', trial_num=''):
    # fixation at beginning of trial (unless it is first trial of the block)
    if trial_num > 0:
        run_fixation(duration=fixation_duration)
    # present word 
    trial_clock.reset()

    # determine the word to display
    if not practice:
        if trial_type == 'negative':
            trial_word = negative_words.pop(0)
        elif trial_type == 'positive':
            trial_word = positive_words.pop(0)
    elif practice:
        trial_word = practice_words.pop(0)
    word.setText(trial_word)
    endExpNow = False
    no.bold = False
    no.italic = False
    yes.bold = False
    yes.italic = False
    word.draw()
    yes.draw()
    no.draw()
    block_type_text.draw()
    win.flip()
    if not practice:
        write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                      expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 
                      'word_presentation', trial_num, trial_word, '', '', '', block_type, trial_type, block_number])
    
    # get participant button press response for word
    continueRoutine = True
    response_endorse=''
    while continueRoutine:            
        trial_time = trial_clock.getTime()
        if trial_time > 0 and trial_time < trial_duration:
            theseKeys = event.getKeys(keyList=[yes_button_number, no_button_number, 'escape'])
            if "escape" in theseKeys:
                endExpNow = True
            # if participant has pressed a button    
            if len(theseKeys) > 0 :
                # change color of selected word
                if no_button_number in theseKeys:
                    no.bold = True
                    no.italic = True
                    response_endorse = 0
                elif yes_button_number in theseKeys:
                    yes.bold = True
                    yes.italic = True
                    response_endorse = 1
                if not practice:  
                    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                                    expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'response', trial_num, 
                                    trial_word, trial_clock.getTime(), theseKeys[0], response_endorse, block_type, trial_type, block_number])
                word.draw()
                yes.draw()
                no.draw()
                block_type_text.draw()
                win.flip()
            if endExpNow:
                win.close()
                convert_sret_csv_to_bids(infile = filename+'_events.csv')
                core.quit()
        else:
            continueRoutine = False 
            if endExpNow:
                convert_sret_csv_to_bids(infile = filename+'_events.csv')
                core.quit()


# Run the practice (only for first run of localizer) / with instructions & checking keys
def run_practice():
    event.clearEvents(eventType='keyboard')
    instruct_text.setText(f'The 3 types of YES or NO questions you will see will be:\
\n\n1) Does a word describe you?\
\n\n2) Does a word describe {expInfo["friend_name"]} (who you mentioned earlier)?\
\n\n3) Is a word positive?')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])

    instruct_text.setText("There are no right or wrong answers!\
\n\nIf you see a word you don't know, you can just wait for the next one")
    instruct_text.draw()
    win.flip()
    event.clearEvents(eventType='keyboard')
    wait_for_keypress(key_list=['space'])

    instruct_text.setText('Each time you answer a question:\
        \n\n\npress the left button to answer YES\n\npress the right button to answer NO')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])
    event.clearEvents(eventType='keyboard')
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press the left button to answer YES')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=[yes_button_number])
    event.clearEvents(eventType='keyboard')
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press the right button to answer NO')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=[no_button_number])
    event.clearEvents(eventType='keyboard')
    instruct_text.setText('Great! We will go through a few practice trials of each type now.\
        \n\nTry to make your decision quickly!')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])

    # Run actual practice trials (6 of them, 2 of each type)
    run_block(n_trials = 0, block_type = 'self', block_number = 0, practice = True)
    run_trial(trial_type = 'self', fixation_duration=1, practice = True, block_type = 'self', trial_num=1)
    run_trial(trial_type = 'self', fixation_duration=1, practice = True, block_type = 'self', trial_num=1)
    run_block(n_trials = 0, block_type = 'other', block_number = 0, practice = True)
    run_trial(trial_type = 'other', fixation_duration=1, practice = True, block_type = 'other', trial_num=1)
    run_trial(trial_type = 'other', fixation_duration=1, practice = True, block_type = 'other', trial_num=1)
    run_block(n_trials = 0, block_type = 'semantic', block_number = 0, practice = True)
    run_trial(trial_type = 'positive', fixation_duration=1, practice = True, block_type = 'semantic', trial_num=1)
    run_trial(trial_type = 'positive', fixation_duration=1, practice = True, block_type = 'semantic', trial_num=1)
    instruct_text.setText('Great job! Any questions on what to do?')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])



'''
Actually run everything!
'''

run_instructions()

# only run practice if it is run 1 of localizer session
if expInfo['run'] == '1' and expInfo['session'] == 'loc':
    run_practice()
elif expInfo['run'] == '1' and expInfo['session'] == 'nf':
    event.clearEvents(eventType='keyboard')
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press the right button to answer NO')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=[no_button_number])
    event.clearEvents(eventType='keyboard')
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press the left button to answer YES')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=[yes_button_number])
    event.clearEvents(eventType='keyboard')

# trigger - timings are relative to this
get_trigger()

# Run each baseline fixation period & block
for block_num in range(block_order.shape[0]):
    run_fixation(8)
    run_block(n_trials = 6, block_type = block_order.block_type[block_num], block_number = block_num)

# Final fixation block at the end of the task
run_fixation(8)

# At end, convert csv to bids-compliant tsv file
convert_sret_csv_to_bids(infile = filename+'_events.csv')


# Shut down
instruct_text.setText('Great job! You have finished this run')
instruct_text.draw()
win.flip()
core.wait(3)
win.close()
core.quit()


