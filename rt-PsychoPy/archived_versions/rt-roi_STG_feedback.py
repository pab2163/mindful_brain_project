#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.81.00), Tue Oct 14 05:54:07 2014
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
import os  # handy system and path functions
from math import floor
import sys 
import time 
from murfi_activation_communicator import MurfiActivationCommunicator 
import csv
import pandas as pd
import math
import socket
import re
import random
from murfi_activation_communicator import MurfiActivationCommunicator # Import murfi communicator here
from os import path

#murfi setups
murfi_FAKE = False

#ROI targets for this real-time experiment
murfi_ROIS= ['stg', 'smc']
exp_tr=1.2 #TR in seconds see Siemens console setup
print("murfi communicator running")
frame=0
feedback_trial_type=[]

#This is the number of seconds for baseline measurement
init_baseline=30
#original baseline 30 sec


# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
expName = 'nf'  # from the Builder filename that created this script
expInfo = {'subject[xxx]':'999', 'session[1/2/3/4]':'ses-nf1', 'task[transferpre/transferpost]or[feedback]':'task-transferpre','run[xx]':'run-01','max':'1','min':'-1','mid':'0'}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# Create stg subject directory
stg_subjDir = _thisDir + os.sep + u'data' + os.sep + expInfo['subject[xxx]']
print(expInfo['subject[xxx]'])
# Create new folder for new subject so final selfref stimulus can be written there
if path.isdir(stg_subjDir) == False:
    os.mkdir(stg_subjDir)
else:
    # If subject folder already exists, output message
    print('This STG subject folder has already been created.')

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
# OUTPUT FILES:
filename = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])  
tsvFile = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events.tsv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])  

#dataFile = open(dataFile +'.%d.dat' % time.time(), 'w+')
print(tsvFile)

# ---------OVERWRITING---------------------
# Check if files with this name already exist
# Set to zero and changed if chosen
overwrite = 0
preserve = 0
exists = 0
matches = []
directory = os.fsencode(stg_subjDir)
for file in os.listdir(directory):
    current_file = os.fsdecode(file)
    if current_file.startswith('sub-R33rtsz%s_%s_%s_%s_events' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']) or 'sub-R33rtsz%s_%s_%s_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])):
        matches.append(current_file)
        exists += 1
matches = '\n'.join([file for file in matches])
#print(matches)
if exists >= 1:
    print(os.path.exists(tsvFile))
    myDlg = gui.Dlg(title=str(exists) +' file(s) with this name already exist', labelButtonOK=' Yes ', labelButtonCancel=' No ')
    myDlg.addText('The following matches were found in the output folder:\n' + matches + '\n\n Overwrite existing files for this run?\n\n If YES:\n All other .log files under the same subject, session, task, and run will be replaced by the outputted .log file.\n\
    All other .tsv files under the same subject, session, task, and run will be replaced by the outputted .tsv file.\n All other .psydat files under the same subject, session, task, and run will be replaced by the outputted .psydat file.\n\
    All other .csv files under the same subject, session, task, and run will be replaced by the outputted .csv file.\n\n If NO:\n An attempt number one value higher than the previous attempt will be added to the created files.')
    ok_data = myDlg.show()  # show dialog and wait for Yes or No
    if myDlg.OK:
        print('User overwrote the previous files.')
        overwrite = 1
    elif myDlg.OK == False:
        print('User did not overwrite the previous files.')
        preserve = 1

rename_files = 0 
removed_files = 0
if overwrite == 1:
    # Since user proceeded with overwriting, 
    # deleting old psydat and csv files to prevent added number on new version
    new_psydat_filename = stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.psydat' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])
    new_csv_filename = stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.csv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])

    directory = os.fsencode(stg_subjDir)
    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        if filename.startswith('sub-R33rtsz%s_%s_%s_%s_events' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])):
           full_filename = stg_subjDir+os.sep+filename
           os.remove(full_filename)
           removed_files +=1
    print(str(removed_files) + ' files removed')
    
    # Creating new files with names that were previously removed
    filename = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])
    tsvFile = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events.tsv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])

elif preserve == 1:
    #print(os.path.exists(tsv_file))
    # Check for filenames with attempts and number of attempt
    attempt_numbers = []
    # folder_filenames = []
    directory = os.fsencode(stg_subjDir)
    for file in os.listdir(directory):
        folder_filename = os.fsdecode(file)
        if folder_filename.startswith('sub-R33rtsz%s_%s_%s_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])):
            #folder_filenames.append(folder_filename)
            attempt_number = folder_filename.replace('sub-R33rtsz%s_%s_%s_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']), '')
            attempt_number = attempt_number.replace('.tsv','')
            attempt_number = attempt_number.replace('.psydat','')
            attempt_number = attempt_number.replace('.csv','')
            attempt_number = attempt_number.replace('.log','')
            attempt_numbers.append(int(attempt_number))
            
#    for file in os.listdir(directory):
#        folder_filename = os.fsdecode(file)
#        if folder_filename.startswith('%s_%s_task-selfreference_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['run[xx]'])):
#            attempt_number = folder_filename.replace('%s_%s_task-selfreference_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['run[xx]']), '')
#            attempt_number = attempt_number.replace('.tsv','')
#            attempt_number = attempt_number.replace('.psydat','')
#            attempt_number = attempt_number.replace('.csv','')
#            attempt_number = attempt_number.replace('.log','')
#            attempt_numbers.append(int(attempt_number))
        else:
            # rename previously exisiting files later in script because their file names (.psydat and .log files) are in use
            #print(os.path.exists(tsv_file))
            rename_files = 1
            #os.rename(selfref_subjDir+os.sep+'%s_%s_%s_%s_events.log' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']), selfref_subjDir+os.sep+'%s_%s_%s_%s_events_attempt1.log' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']))
            #os.rename(selfref_subjDir+os.sep+'%s_%s_%s_%s_events.tsv' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']), selfref_subjDir+os.sep+'%s_%s_%s_%s_events_attempt1.tsv' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']))
            #os.rename(selfref_subjDir+os.sep+'%s_%s_%s_%s_events.psydat' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']), selfref_subjDir+os.sep+'%s_%s_%s_%s_events_attempt1.psydat' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']))
            #os.rename(selfref_subjDir+os.sep+'%s_%s_%s_%s_events.csv' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']), selfref_subjDir+os.sep+'%s_%s_%s_%s_events_attempt1.csv' %(expInfo['subject[xxx]'], expInfo['session[localizer/nf1/nf2/nf3/nf4]'], expInfo['task[transfer]or[feedback]'], expInfo['run[xx]']))
            filename = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events_attempt2' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])
            tsvFile = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events_attempt2.tsv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])
    #print(attempt_numbers)
    #print(folder_filenames)
    for file in os.listdir(directory):
        folder_filename = os.fsdecode(file)
        if folder_filename.startswith('sub-R33rtsz%s_%s_%s_%s_events_attempt' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'])):
            # rename new files based on latest attempt
            latest_attempt = max(attempt_numbers)
            #print('Latest attempt is attempt ', latest_attempt)
            filename = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events_attempt%s' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'], latest_attempt + 1)
            tsvFile = stg_subjDir + os.sep + 'sub-R33rtsz%s_%s_%s_%s_events_attempt%s' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]'], latest_attempt + 1)

# --------- END OF OVERWRITING -------------------------------------
tsv_header = ['onset','duration','trial_type','block_count','block_type','response','response_time','stg_activity','smc_activity','feedback','stim_file','date']
with open(tsvFile, "a",newline="") as f_tsv:
    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
    tsv_writer.writerow(tsv_header) # write the header

###this looks into the randomization of subjects and asigns either real or sham feedback###
###treatment = 1 = real = stg###

df = pd.read_excel('schedule/randomization/Master_Participant_List.xlsx') #this file contains the initial randomization of subjects
print(expInfo['session[1/2/3/4]'])
if expInfo['session[1/2/3/4]'] == 'ses-nf1' or expInfo['session[1/2/3/4]'] == 'ses-nf2':
    for sub in range(0,105):
        if 'R33rtsz'+expInfo['subject[xxx]'] == df.loc[sub,'SUBID']:
            blinding = df.loc[sub,'Active(1)/Sham(0)']
            print('allocating %s to randomization group %s' %('R33rtsz'+expInfo['subject[xxx]'],blinding))
            break
        else:
            print('allocating %s to randomization group' %('R33rtsz'+expInfo['subject[xxx]']))
else:
    blinding = 1
    print('R33rtsz'+expInfo['subject[xxx]'],expInfo['session[1/2/3/4]'],'all real group.',blinding)

#### now lets see if it is a transfer run or a feedback run###
if expInfo['task[transferpre/transferpost]or[feedback]'] =='task-feedback':
    show_feedback=True
    print('feedback session')
else:
    show_feedback=False
    print('no feedback session')
    
# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True, saveWideText=True,
    dataFileName=filename)
#save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(size=(400, 200), fullscr=True, screen=1, allowGUI=False, allowStencil=False,
#win = visual.Window(size=(1920, 1080), fullscr=True, screen=1, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[-1,-1,-1], colorSpace='rgb',
    blendMode='avg',
    )
# store frame rate of monitor if we can measure it successfully
#expInfo['frameRate']=win.getActualFrameRate()
#if expInfo['frameRate']!=None:
#    frameDur = 1.0/round(expInfo['frameRate'])
#else:
frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "pretrigger_instr"
pretrigger_instrClock = core.Clock()
text = visual.TextStim(win=win, ori=0, name='text',
    text=u'In this task you will be asked to either attend to your own voice or ignore all sounds including the voices and any other noise in the environment.\n\nWhen ignoring sounds, you may use "noting practice" strategy suggested by the experimenter. \n\nWhen you are ready please press the "YES" button.',    font=u'Arial',
    pos=[0, 0], height=0.08, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)
    
condition_file=os.path.join('schedule',expInfo['subject[xxx]'],'sub-R33rtsz%s_%s_%s_%s.csv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']))  
print(condition_file)#'%s_STG_day%srun%s.csv'%(expInfo['participant'], expInfo['day'], expInfo['run']))


class Murfi:
	def __init__(self, ip, port, tr, fake,murfi_ROIS):
		self.IP = ip
		self.PORT = port
		self.TR = tr
		self.FAKE = fake
		self.rois_fake= murfi_ROIS
	
		self.FB_stg = [float('NaN')] * self.TR
		self.FB_smc = [float('NaN')] * self.TR
		#self.FB_FFA = [0] * self.TR
		#self.FB_PPA = [0] * self.TR
        
		self.stg_query = '<?xml version="1.0" encoding="UTF-8"?><info><get dataid=":*:*:*:__TR__:*:*:roi-weightedave:stg:"></get></info>\n'
		self.smc_query = '<?xml version="1.0" encoding="UTF-8"?><info><get dataid=":*:*:*:__TR__:*:*:roi-weightedave:smc:"></get></info>\n'
		#print(self.smc_query)
	def sendQ(self, Q):
		if not self.FAKE:		
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((self.IP, self.PORT))
			s.sendall(Q.encode('utf-8'))
			A = s.recv(4096)
			s.close()

			return A
		else:
			#print( "::::DEBUG MODE.RUNNING MURFI SIMULATOR::::")
			A = str(random.gauss(0,1))
			A = A.encode()
			return A

			time.sleep(exp_tr)
			#return A #str(random.gauss(0,1))
			#print("got random:",A)

	def stripA(self, A):	
		first_re="<.*?>"
		first_re = first_re.encode()
		second_re=""
		second_re = second_re.encode()
		Astrip = re.sub(first_re,second_re,A)
		#print "Astrip: ", Astrip
		try:
			stripped = float(Astrip)
		except ValueError:
			stripped = float('nan')
		#print "Stripped is returning: ", stripped, A
		return stripped

	# These are 1-indexed (like murfi)
	def Q_stg(self, tr):
		if tr>self.TR:
			print ("Q_stg(self, tr): ERROR: TR Out of Bounds")
			return		
		thisQ = self.stg_query.replace('__TR__', str(tr))				
		A = self.sendQ(thisQ)
		self.FB_stg[tr-1] = self.stripA(A)		
	
	# These are 1-indexed (like murfi)	
	def Q_smc(self, tr):
		if tr>self.TR:
			print ("Q_smc(self, tr): ERROR: TR Out of Bounds")
			return	
		thisQ = self.smc_query.replace('__TR__', str(tr))
		A = self.sendQ(thisQ)	
		self.FB_smc[tr-1] = self.stripA(A)

	def update(self):
		#print ("communicator  update")
		stg_tr = self.TR-1
		for ii in range(0, self.TR-1):
			#print "ii:",  ii
			if math.isnan(self.FB_stg[ii]):
				stg_tr = ii
				break
		
		smc_tr = self.TR-1
		for ii in range(0, self.TR-1):
			#print "ii:",  ii
			if math.isnan(self.FB_smc[ii]):
				smc_tr = ii
				break

		#print("stg_tr:",murfi.FB_stg,"smc_tr:",murfi.FB_smc)
		#print ("smc_tr:", smc_tr)
		
		for ii in range(stg_tr, self.TR-1):
			#print "Q_ffa:", ii			
			self.Q_stg(ii+1)
			#print "Q_stg:",ii
			if math.isnan(self.FB_stg[ii]):
				break

		for ii in range(smc_tr, self.TR-1):
			self.Q_smc(ii+1)
			#print "Q_smc:",ii
			if math.isnan(self.FB_smc[ii]):
				break
		return
	#time.sleep(1) 
murfi_IP = '192.168.2.5'
#murfi_IP='192.168.1.19'
murfi_PORT = 15001
murfi_TR = 167  #number of measurements
murfi_count=0


if murfi_FAKE:
    print( "::::IN DEBUG MODE.RUNNING MURFI SIMULATOR::::")

murfi = Murfi(murfi_IP, murfi_PORT, murfi_TR, murfi_FAKE,murfi_ROIS)
murfi.update()
#print("murfi update 1")
#print(murfi.FB_stg)
#print(murfi.FB_smc)


#create output data file
#datFile=open('data'+os.path.sep+'STG_real_feedback_%s_%s.txt'%(expInfo['participant'],expInfo['date']),'w')
#datFile=open('data'+os.path.sep+'%s_%s_%s_%s.txt' %(expInfo['subject[xxx]'], expInfo['session[1,2,3,4]'], expInfo['task[transfer]or[feedback]'],expInfo['run[xx]']))


# Initialize components for Routine "trigger"
triggerClock = core.Clock()
StartedTrialClock=core.Clock()
text_2 = visual.TextStim(win=win, ori=0, name='text_2',
    text=u'waiting for scanner\n',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

# Initialize components for Routine "baseline"
baselineClock = core.Clock()
image = visual.TextStim(win=win, ori=0, name='image',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


# Initialize components for Routine "instruction"
instructionClock = core.Clock()
instruction = visual.TextStim(win=win, ori=0, name='instruction',
    text='default text',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "transition"
transitionClock = core.Clock()
image_transition = visual.TextStim(win=win, ori=0, name='image_transition',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "stimulus_1"
stimulus_1Clock = core.Clock()
image_stimulus_1 = visual.TextStim(win=win, ori=0, name='image_stimulus_1',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
sound_1 = sound.Sound('A', secs=3.5, stereo=True)
sound_1.setVolume(1)

# Initialize components for Routine "stimulus_2"
stimulus_2Clock = core.Clock()
image_stimulus_2 = visual.TextStim(win=win, ori=0, name='image_stimulus_2',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
sound_2 = sound.Sound('A', secs=3.5, stereo=True)
sound_2.setVolume(1)

# Initialize components for Routine "stimulus_3"
stimulus_3Clock = core.Clock()
image_stimulus_3 = visual.TextStim(win=win, ori=0, name='image_stimulus_3',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
sound_3 = sound.Sound('A', secs=3.5, stereo=True)
sound_3.setVolume(1)

# Initialize components for Routine "stimulus_4"
stimulus_4Clock = core.Clock()
image_stimulus_4 = visual.TextStim(win=win, ori=0, name='image_stimulus_4',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
sound_4 = sound.Sound('A', secs=3.5, stereo=True)
sound_4.setVolume(1)




# Initialize components for Routine "rating"
ratingClock = core.Clock()
text_4 = visual.TextStim(win=win, ori=0, name='text_4',
    text='',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
rating = visual.RatingScale(win=win, name='rating', marker='triangle',size=1.0, pos=[0.0,-0.3], low = 1, high =  6, labels=['Completely','Not at all'],markerStart='3.5', leftKeys='1',rightKeys='2',scale=None)

# Initialize components for Routine "feedback"
feedbackClock = core.Clock()
image_8 = visual.TextStim(win=win, ori=0, name='image_8',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


# Initialize components for Routine "fixation_2"
fixation_2Clock = core.Clock()
image_fixation_2 = visual.TextStim(win=win, ori=0, name='image_fixation_2',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


# Initialize components for Routine "end"
endClock = core.Clock()

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

#------Prepare to start Routine "pretrigger_instr"-------
t = 0
pretrigger_instrClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
key_resp_2 = event.BuilderKeyResponse()  # create an object of type KeyResponse
key_resp_2.status = NOT_STARTED

# keep track of which components have finished
pretrigger_instrComponents = []
pretrigger_instrComponents.append(key_resp_2)
pretrigger_instrComponents.append(text)
for thisComponent in pretrigger_instrComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "pretrigger_instr"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = pretrigger_instrClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *key_resp_2* updates
    if t >= 0.0 and key_resp_2.status == NOT_STARTED:
        # keep track of start time/frame for later
        key_resp_2.tStart = t  # underestimates by a little under one frame
        key_resp_2.frameNStart = frameN  # exact frame index
        key_resp_2.status = STARTED
        # keyboard checking is just starting
        key_resp_2.clock.reset()  # now t=0
        event.clearEvents(eventType='keyboard')
    if key_resp_2.status == STARTED:
        theseKeys = event.getKeys(keyList=['space','num_1','1', '2','3','4'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            key_resp_2.keys = theseKeys[-1]  # just the last key pressed
            key_resp_2.rt = round(key_resp_2.clock.getTime(),2)
            # a response ends the routine
            continueRoutine = False
    
    # *text* updates
    if t >= 0.0 and text.status == NOT_STARTED:
        # keep track of start time/frame for later
        text.tStart = t  # underestimates by a little under one frame
        text.frameNStart = frameN  # exact frame index
        text.setAutoDraw(True)
    
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in pretrigger_instrComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()
    else:  # this Routine was not non-slip safe so reset non-slip timer
        routineTimer.reset()

#-------Ending Routine "pretrigger_instr"-------
for thisComponent in pretrigger_instrComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp_2.keys in ['', [], None]:  # No response was made
   key_resp_2.keys='n/a'
# store data for thisExp (ExperimentHandler)
# thisExp.addData('key_resp_2.keys',key_resp_2.keys)
# if key_resp_2.keys != None:  # we had a response
#     thisExp.addData('key_resp_2.rt', key_resp_2.rt)
# thisExp.nextEntry()


#------Prepare to start Routine "trigger"-------
t = 0
triggerClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
trigger_button = event.BuilderKeyResponse()  # create an object of type KeyResponse
trigger_button.status = NOT_STARTED
# keep track of which components have finished
triggerComponents = []
triggerComponents.append(trigger_button)
triggerComponents.append(text_2)
for thisComponent in triggerComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "trigger"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = triggerClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *trigger_button* updates
    if t >= 0.0 and trigger_button.status == NOT_STARTED:
        # keep track of start time/frame for later
        trigger_button.tStart = t  # underestimates by a little under one frame
        trigger_button.frameNStart = frameN  # exact frame index
        trigger_button.status = STARTED
        # keyboard checking is just starting
        trigger_button.clock.reset()  # now t=0
        event.clearEvents(eventType='keyboard')
    if trigger_button.status == STARTED:
        theseKeys = event.getKeys(keyList=['num_add', 't','5'])
        StartedTrialClock.reset()  # clock 
        #print('trial clock:',StartedTrialClock.getTime())
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            trigger_button.keys = theseKeys[-1]  # just the last key pressed
            trigger_button.rt = round(trigger_button.clock.getTime(),2)
            #thisExp.addData('onset',int(StartedTrialClock.getTime())) #this is where the clock of the trial starts
            #datFile.addData('onset',int(StartedTrialClock.getTime())) #wirte to tsv
            print('trial clock:',StartedTrialClock.getTime())
            
            # a response ends the routine
            continueRoutine = False
    
    # *text_2* updates
    if t >= 0.0 and text_2.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_2.tStart = t  # underestimates by a little under one frame
        text_2.frameNStart = frameN  # exact frame index
        text_2.setAutoDraw(True)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in triggerComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()
    else:  # this Routine was not non-slip safe so reset non-slip timer
        routineTimer.reset()

#-------Ending Routine "trigger"-------
for thisComponent in triggerComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if trigger_button.keys in ['', [], None]:  # No response was made
   trigger_button.keys='n/a'
# store data for thisExp (ExperimentHandler)
thisExp.addData('trigger_button.keys',trigger_button.keys)
#store the time for the beggining of trial

if trigger_button.keys != 'n/a':  # we had a response
    thisExp.addData('trigger_button.rt', trigger_button.rt)
    thisExp.nextEntry()



#------Prepare to start Routine "baseline"-------
t = 0
baselineClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
# Initialize components for Routine "feedback"
stg_vector_all=[]
smc_vector_all=[]
#vector_indices=[[25,36],[62,75],[99,110],[135,146]]  #TR length of 1.2

vector_indices=[[26,37],[63,76],[100,111],[136,147]]  #TR length of 1.2
#vector_indices=[[17,24],[39,46],[61,68],[83,90],[17,90]] #TR length of 2

#Draw thermometer
top_condition='listen to self'
bottom_condition='ignore all sounds'
self_other_conditions=[]
block_count=0
background_bar = visual.ShapeStim(win=win, name='background_bar', lineWidth=2.0, lineColor=(1.0,1.0,1.0), lineColorSpace='rgb',
pos=(0,0),size=1,opacity=1,depth=2,interpolate=True,vertices=((-.125,-.5),(.125,-.5),(.125,.5),(-.125,.5)))#, fillColor='white', fillColorSpace='rgb')
zero_val_line=visual.ShapeStim(win=win, name='zero_val_line', lineWidth=2.0, lineColor=(1.0,1.0,1.0),lineColorSpace='rgb',
pos=(0,0),size=1,opacity=1,depth=2,interpolate=True,vertices=((-.125,0),(.125,0)))
zero=visual.TextStim(win,text='0',font='', pos=(.155,0),depth=2,rgb=None,color=(1.0,1.0,1.0),colorSpace='rgb',opacity=1.0)
top_text=visual.TextStim(win,text='placeholder',pos=(0,.6),depth=2,rgb=None,color=(1.0,1.0,1.0),colorSpace='rgb',opacity=1.0)
bottom_text=visual.TextStim(win,text='placeholder',pos=(0,-.6),depth=2,rgb=None,color=(1.0,1.0,1.0),colorSpace='rgb',opacity=1.0)
top_star = visual.TextStim(win=win, ori=0, name='top_star',
    text=u'*',    font=u'Arial',
    pos=[.5, .5], height=0.5, wrapWidth=None,
    color=u'white', colorSpace=u'rgb', opacity=1,
    depth=-2.0)
bottom_star = visual.TextStim(win=win, ori=0, name='top_star',
    text=u'*',    font=u'Arial',
    pos=[.5, -.5], height=0.5, wrapWidth=None,
    color=u'white', colorSpace=u'rgb', opacity=1,
    depth=-2.0)
    
# keep track of which components have finished
baselineComponents = []
baselineComponents.append(image)
for thisComponent in baselineComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
def makeFBrecs(zero_val,fb,fillColor=None,xoffset=0):
    murfi.update()
    stg_vector_all.append(murfi.FB_stg)
    smc_vector_all.append(murfi.FB_smc)
    #print"murfi update 2",murfi.update()
    if instruction_text=='ignore all sounds':
        if fb >=zero_val:
            rec_height=1*(fb-zero_val)/(30*(max-zero_val))*.5
            for idx in range(30):
                rec=visual.ShapeStim(win, closeShape=True, vertices=((xoffset-.125,idx*rec_height),(xoffset+.125,idx*rec_height),(xoffset+.125,(idx+1)*rec_height),(xoffset-.125,(idx+1)*rec_height)),depth=-3,opacity=1,fillColor='Red',lineColor='Red')
                recs.append(rec)
        elif fb<zero_val:
            rec_height=(fb-zero_val)/(30*(min-zero_val))*.5
            for idx in range(30):
                rec=visual.ShapeStim(win, closeShape=True, vertices=((xoffset-.125,idx*-1*rec_height),(xoffset+.125,idx*-1*rec_height),(xoffset+.125,(idx+1)*-1*rec_height),(xoffset-.125,(idx+1)*-1*rec_height)),depth=-3,opacity=1,fillColor='Green',lineColor='Green')
                recs.append(rec)
    if instruction_text=='listen to self':
        if fb >=zero_val:
            rec_height=1*(fb-zero_val)/(30*(max-zero_val))*.5
            for idx in range(30):
                rec=visual.ShapeStim(win, closeShape=True, vertices=((xoffset-.125,idx*rec_height),(xoffset+.125,idx*rec_height),(xoffset+.125,(idx+1)*rec_height),(xoffset-.125,(idx+1)*rec_height)),depth=-3,opacity=1,fillColor='Green',lineColor='Green')
                recs.append(rec)
        elif fb<zero_val:
            rec_height=(fb-zero_val)/(30*(min-zero_val))*.5
            for idx in range(30):
                rec=visual.ShapeStim(win, closeShape=True, vertices=((xoffset-.125,idx*-1*rec_height),(xoffset+.125,idx*-1*rec_height),(xoffset+.125,(idx+1)*-1*rec_height),(xoffset-.125,(idx+1)*-1*rec_height)),depth=-3,opacity=1,fillColor='Red',lineColor='Red')
                recs.append(rec)
    return recs
    
#-------Start Routine "baseline"-------
continueRoutine = True
print("starting baseline",round(StartedTrialClock.getTime(),1))
#thisExp.addData('onset',int(StartedTrialClock.getTime())) #this is where the clock of the trial starts
#thisExp.addData('trial_type','baseline')

baseline_save=[round(StartedTrialClock.getTime(),1),init_baseline,"baseline",'','baseline','','','','+',expInfo['date']]
with open(tsvFile, "a",newline="") as f_tsv:
    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
    tsv_writer.writerow(baseline_save) # write the header

while continueRoutine:
    # get current time
    murfi.update()#communicator.update()
    stg_vector_all.append(murfi.FB_stg)
    smc_vector_all.append(murfi.FB_smc)
    #print"murfi update baseline"
    
    t = baselineClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *image* updates
    if t >= 0.0 and image.status == NOT_STARTED:
        # keep track of start time/frame for later
        image.tStart = t  # underestimates by a little under one frame
        image.frameNStart = frameN  # exact frame index
        image.setAutoDraw(True)
    elif image.status == STARTED and t >=((init_baseline)):
        image.setAutoDraw(False)
    
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in baselineComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

    else:  # this Routine was not non-slip safe so reset non-slip timer
        routineTimer.reset()

#-------Ending Routine "baseline"-------
for thisComponent in baselineComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)


# set up handler to look after randomisation of conditions etc
block_order = data.TrialHandler(nReps=1, method='sequential', 
    extraInfo=expInfo, originPath=None,
    trialList=data.importConditions(condition_file),
    seed=None, name='block_order')
thisExp.addLoop(block_order)  # add the loop to the experiment
thisBlock_order = block_order.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisBlock_order.rgb)
# if thisBlock_order != None:
#     print(thisBlock_order.keys())
#     for paramName in thisBlock_order.keys():
#         exec('{} = thisBlock_order[paramName]'.format(paramName))

for thisBlock_order in block_order:
    currentLoop = block_order
    # abbreviate parameter names if possible (e.g. rgb = thisBlock_order.rgb)
    if thisBlock_order != None:
        for paramName in thisBlock_order.keys():
            exec('{} = thisBlock_order[paramName]'.format(paramName))
    
    #------Prepare to start Routine "instruction"-------
    t = 0
    instructionClock.reset()  # clock 
    frameN = -1
    routineTimer.add(2.000000)
    ### Time for tsv ###
    instruction_time=round(StartedTrialClock.getTime(),1)
    # update component parameters for each repeat
    instruction.setText(instruction_text)
    feedback_trial_type.append(instruction_text)
    
    # keep track of which components have finished
    instructionComponents = []
    instructionComponents.append(instruction)
    for thisComponent in instructionComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "instruction"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = instructionClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *instruction* updates
        if t >= 0.0 and instruction.status == NOT_STARTED:
            # keep track of start time/frame for later
            instruction.tStart = t  # underestimates by a little under one frame
            instruction.frameNStart = frameN  # exact frame index
            instruction.setAutoDraw(True)
        elif instruction.status == STARTED and t >= (0.0 + (2.0)): #most of one frame period left
            instruction.setAutoDraw(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineTimer.reset()  # if we abort early the non-slip timer needs reset
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in instructionComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
            
    
    #-------Ending Routine "instruction"-------
    for thisComponent in instructionComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
            #### Write to tsv ####
            instruction_save = [instruction_time,2,instruction_text,block_count+1,'instruction','','','','','',instruction_text,expInfo['date']]
            with open(tsvFile, "a",newline="") as f_tsv:
                tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                tsv_writer.writerow(instruction_save) # write the header
    
    # set up handler to look after randomisation of conditions etc
    voice_1 = data.TrialHandler(nReps=1, method='sequential', 
    #voice_1 = data.TrialHandler(nReps=1, method='sequential', #PILOT_TEST
        extraInfo=expInfo, originPath=None,
        trialList=[None],
        seed=None, name='voice_1')
    thisExp.addLoop(voice_1)  # add the loop to the experiment
    thisVoice_1 = voice_1.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisVoice_1.rgb)
    if thisVoice_1 != None:
        for paramName in thisVoice_1.keys():
            exec('{} = thisVoice_1[paramName]'.format(paramName))
    
    for thisVoice_1 in voice_1:
        currentLoop = voice_1
        # abbreviate parameter names if possible (e.g. rgb = thisVoice_1.rgb)
        if thisVoice_1 != None:
            for paramName in thisVoice_1.keys():
                exec('{} = thisVoice_1[paramName]'.format(paramName))
        
        #------Prepare to start Routine "transition"-------
        t = 0
        transitionClock.reset()  # clock 
        frameN = -1
        routineTimer.add(0.500000)
        ### Time for tsv ###
        transition_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        # keep track of which components have finished
        transitionComponents = []
        transitionComponents.append(image_transition)
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "transition"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = transitionClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *image_transition* updates
            if t >= 0.0 and image_transition.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_transition.tStart = t  # underestimates by a little under one frame
                image_transition.frameNStart = frameN  # exact frame index
                image_transition.setAutoDraw(True)
            elif image_transition.status == STARTED and t >= (0.0 + (.5)): #most of one frame period left
                image_transition.setAutoDraw(False)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in transitionComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "transition"-------
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                transition_save = [transition_time,0.5,'transition',block_count+1,instruction_text,'','','','','','+',expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(transition_save) # write the header
        
        #------Prepare to start Routine "stimulus_1"-------
        t = 0
        stimulus_1Clock.reset()  # clock 
        frameN = -1
        routineTimer.add(3.500000)
        ### Time for tsv ###
        voice_file1_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        sound_1.setSound(voice_file1)
        print(voice_file1)
        # keep track of which components have finished
        stimulus_1Components = []
        stimulus_1Components.append(image_stimulus_1)
        stimulus_1Components.append(sound_1)
        for thisComponent in stimulus_1Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "stimulus_1"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = stimulus_1Clock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # ET ADDED
            # CueOnset = globalClock.getTime() # underestimates by a little under one frame          
            # thisExp.addData('CueOnset',CueOnset)
            # *image_stimulus_1* updates
            if t >= 0.0 and image_stimulus_1.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_stimulus_1.tStart = t  # underestimates by a little under one frame
                image_stimulus_1.frameNStart = frameN  # exact frame index
                image_stimulus_1.setAutoDraw(True)
            elif image_stimulus_1.status == STARTED and t >= (0.0 + (3.5)):#most of one frame period left
                image_stimulus_1.setAutoDraw(False)
            # start/stop sound_1
            if t >= 0.0 and sound_1.status == NOT_STARTED:
                # keep track of start time/frame for later
                sound_1.tStart = t  # underestimates by a little under one frame
                sound_1.frameNStart = frameN  # exact frame index
                sound_1.play()  # start the sound (it finishes automatically)
            elif sound_1.status == STARTED and t >= (0.0 + (3.5)): #most of one frame period left
                sound_1.stop()  # stop the sound (if longer than duration)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in stimulus_1Components:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "stimulus_1"-------
        for thisComponent in stimulus_1Components:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                stimulus_1_save = [voice_file1_time,3.5,'voice_file',block_count+1,instruction_text,'','','','','',voice_file1,expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(stimulus_1_save) # write the header
        thisExp.nextEntry()


    # set up handler to look after randomisation of conditions etc
    voice_2 = data.TrialHandler(nReps=1, method='sequential', 
    #voice_2 = data.TrialHandler(nReps=1, method='sequential', #PILOT_TEST
        extraInfo=expInfo, originPath=None,
        trialList=[None],
        seed=None, name='voice_2')
    thisExp.addLoop(voice_2)  # add the loop to the experiment
    thisVoice_2 = voice_2.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisVoice_2.rgb)
    if thisVoice_2 != None:
        for paramName in thisVoice_2.keys():
            exec('{} = thisVoice_2[paramName]'.format(paramName))
    
    for thisVoice_2 in voice_2:
        currentLoop = voice_2
        # abbreviate parameter names if possible (e.g. rgb = thisVoice_2.rgb)
        if thisVoice_2 != None:
            for paramName in thisVoice_2.keys():
                exec('{} = thisVoice_2[paramName]'.format(paramName))
        
        #------Prepare to start Routine "transition"-------
        t = 0
        transitionClock.reset()  # clock 
        frameN = -1
        routineTimer.add(0.500000)
        ### Time for tsv ###
        transition_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        # keep track of which components have finished
        transitionComponents = []
        transitionComponents.append(image_transition)
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "transition"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = transitionClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *image_transition* updates
            if t >= 0.0 and image_transition.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_transition.tStart = t  # underestimates by a little under one frame
                image_transition.frameNStart = frameN  # exact frame index
                image_transition.setAutoDraw(True)
            elif image_transition.status == STARTED and t >= (0.0 + (.5)): #most of one frame period left
                image_transition.setAutoDraw(False)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in transitionComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "transition"-------
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                transition_save = [transition_time,0.5,'transition',block_count+1,instruction_text,'','','','','','+',expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(transition_save) # write the header
        
        #------Prepare to start Routine "stimulus_2"-------
        t = 0
        stimulus_2Clock.reset()  # clock 
        frameN = -1
        routineTimer.add(3.500000)
        ### Time for tsv ###
        voice_file2_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        sound_2.setSound(voice_file2)
        print(voice_file2)
        # keep track of which components have finished
        stimulus_2Components = []
        stimulus_2Components.append(image_stimulus_2)
        stimulus_2Components.append(sound_2)
        for thisComponent in stimulus_2Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "stimulus_2"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = stimulus_2Clock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # ET ADDED
            # CueOnset = globalClock.getTime() # underestimates by a little under one frame          
            # thisExp.addData('CueOnset',CueOnset)
            # *image_stimulus_2* updates
            if t >= 0.0 and image_stimulus_2.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_stimulus_2.tStart = t  # underestimates by a little under one frame
                image_stimulus_2.frameNStart = frameN  # exact frame index
                image_stimulus_2.setAutoDraw(True)
            elif image_stimulus_2.status == STARTED and t >= (0.0 + (3.5)):#most of one frame period left
                image_stimulus_2.setAutoDraw(False)
            # start/stop sound_2
            if t >= 0.0 and sound_2.status == NOT_STARTED:
                # keep track of start time/frame for later
                sound_2.tStart = t  # underestimates by a little under one frame
                sound_2.frameNStart = frameN  # exact frame index
                sound_2.play()  # start the sound (it finishes automatically)
            elif sound_2.status == STARTED and t >= (0.0 + (3.5)): #most of one frame period left
                sound_2.stop()  # stop the sound (if longer than duration)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in stimulus_2Components:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "stimulus_2"-------
        for thisComponent in stimulus_2Components:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                stimulus_2_save = [voice_file2_time,3.5,'voice_file',block_count+1,instruction_text,'','','','','',voice_file2,expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(stimulus_2_save) # write the header
        thisExp.nextEntry()
    

    # set up handler to look after randomisation of conditions etc
    voice_3 = data.TrialHandler(nReps=1, method='sequential', 
    #voice_3 = data.TrialHandler(nReps=1, method='sequential', #PILOT_TEST
        extraInfo=expInfo, originPath=None,
        trialList=[None],
        seed=None, name='voice_3')
    thisExp.addLoop(voice_3)  # add the loop to the experiment
    thisVoice_3 = voice_3.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisVoice_3.rgb)
    if thisVoice_3 != None:
        for paramName in thisVoice_3.keys():
            exec('{} = thisVoice_3[paramName]'.format(paramName))
    
    for thisVoice_3 in voice_3:
        currentLoop = voice_3
        # abbreviate parameter names if possible (e.g. rgb = thisVoice_3.rgb)
        if thisVoice_3 != None:
            for paramName in thisVoice_3.keys():
                exec('{} = thisVoice_3[paramName]'.format(paramName))
        
        #------Prepare to start Routine "transition"-------
        t = 0
        transitionClock.reset()  # clock 
        frameN = -1
        routineTimer.add(0.500000)
        ### Time for tsv ###
        transition_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        # keep track of which components have finished
        transitionComponents = []
        transitionComponents.append(image_transition)
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "transition"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = transitionClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *image_transition* updates
            if t >= 0.0 and image_transition.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_transition.tStart = t  # underestimates by a little under one frame
                image_transition.frameNStart = frameN  # exact frame index
                image_transition.setAutoDraw(True)
            elif image_transition.status == STARTED and t >= (0.0 + (.5)): #most of one frame period left
                image_transition.setAutoDraw(False)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in transitionComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "transition"-------
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                transition_save=[transition_time,0.5,'transition',block_count+1,instruction_text,'','','','','','+',expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(transition_save) # write the header
        
        #------Prepare to start Routine "stimulus_3"-------
        t = 0
        stimulus_3Clock.reset()  # clock 
        frameN = -1
        routineTimer.add(3.500000)
        ### Time for tsv ###
        voice_file3_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        sound_3.setSound(voice_file3)
        print(voice_file3)
        # keep track of which components have finished
        stimulus_3Components = []
        stimulus_3Components.append(image_stimulus_3)
        stimulus_3Components.append(sound_3)
        for thisComponent in stimulus_3Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "stimulus_3"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = stimulus_3Clock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # ET ADDED
            # CueOnset = globalClock.getTime() # underestimates by a little under one frame          
            # thisExp.addData('CueOnset',CueOnset)
            # *image_stimulus_3* updates
            if t >= 0.0 and image_stimulus_3.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_stimulus_3.tStart = t  # underestimates by a little under one frame
                image_stimulus_3.frameNStart = frameN  # exact frame index
                image_stimulus_3.setAutoDraw(True)
            elif image_stimulus_3.status == STARTED and t >= (0.0 + (3.5)):#most of one frame period left
                image_stimulus_3.setAutoDraw(False)
            # start/stop sound_3
            if t >= 0.0 and sound_3.status == NOT_STARTED:
                # keep track of start time/frame for later
                sound_3.tStart = t  # underestimates by a little under one frame
                sound_3.frameNStart = frameN  # exact frame index
                sound_3.play()  # start the sound (it finishes automatically)
            elif sound_3.status == STARTED and t >= (0.0 + (3.5)): #most of one frame period left
                sound_3.stop()  # stop the sound (if longer than duration)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in stimulus_3Components:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "stimulus_3"-------
        for thisComponent in stimulus_3Components:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                stimulus_3_save = [voice_file3_time,3.5,'voice_file',block_count+1,instruction_text,'','','','','',voice_file3,expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(stimulus_3_save) # write the header
        thisExp.nextEntry()

    # set up handler to look after randomisation of conditions etc
    voice_4 = data.TrialHandler(nReps=1, method='sequential', 
    #voice_4 = data.TrialHandler(nReps=1, method='sequential', #PILOT_TEST
        extraInfo=expInfo, originPath=None,
        trialList=[None],
        seed=None, name='voice_4')
    thisExp.addLoop(voice_4)  # add the loop to the experiment
    thisVoice_4 = voice_4.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisVoice_4.rgb)
    if thisVoice_4 != None:
        for paramName in thisVoice_4.keys():
            exec('{} = thisVoice_4[paramName]'.format(paramName))
    
    for thisVoice_4 in voice_4:
        currentLoop = voice_4
        # abbreviate parameter names if possible (e.g. rgb = thisVoice_4.rgb)
        if thisVoice_4 != None:
            for paramName in thisVoice_4.keys():
                exec('{} = thisVoice_4[paramName]'.format(paramName))
        
        #------Prepare to start Routine "transition"-------
        t = 0
        transitionClock.reset()  # clock 
        frameN = -1
        routineTimer.add(0.500000)
        ### Time for tsv ###
        transition_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        # keep track of which components have finished
        transitionComponents = []
        transitionComponents.append(image_transition)
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "transition"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = transitionClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *image_transition* updates
            if t >= 0.0 and image_transition.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_transition.tStart = t  # underestimates by a little under one frame
                image_transition.frameNStart = frameN  # exact frame index
                image_transition.setAutoDraw(True)
            elif image_transition.status == STARTED and t >= (0.0 + (.5)): #most of one frame period left
                image_transition.setAutoDraw(False)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in transitionComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "transition"-------
        for thisComponent in transitionComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                transition_save=[transition_time,0.5,'transition',block_count+1,instruction_text,'','','','','','+',expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(transition_save) # write the header
        
        #------Prepare to start Routine "stimulus_4"-------
        t = 0
        stimulus_4Clock.reset()  # clock 
        frameN = -1
        routineTimer.add(3.500000)
        ### Time for tsv ###
        voice_file4_time=round(StartedTrialClock.getTime(),1)
        # update component parameters for each repeat
        sound_4.setSound(voice_file4)
        print(voice_file4)
        # keep track of which components have finished
        stimulus_4Components = []
        stimulus_4Components.append(image_stimulus_4)
        stimulus_4Components.append(sound_4)
        for thisComponent in stimulus_4Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "stimulus_4"-------
        continueRoutine = True
        while continueRoutine and routineTimer.getTime() > 0:
            # get current time
            t = stimulus_4Clock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # ET ADDED
            # CueOnset = globalClock.getTime() # underestimates by a little under one frame          
            # thisExp.addData('CueOnset',CueOnset)
            # *image_stimulus_4* updates
            if t >= 0.0 and image_stimulus_4.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_stimulus_4.tStart = t  # underestimates by a little under one frame
                image_stimulus_4.frameNStart = frameN  # exact frame index
                image_stimulus_4.setAutoDraw(True)
            elif image_stimulus_4.status == STARTED and t >= (0.0 + (3.5)):#most of one frame period left
                image_stimulus_4.setAutoDraw(False)
            # start/stop sound_4
            if t >= 0.0 and sound_4.status == NOT_STARTED:
                # keep track of start time/frame for later
                sound_4.tStart = t  # underestimates by a little under one frame
                sound_4.frameNStart = frameN  # exact frame index
                sound_4.play()  # start the sound (it finishes automatically)
            elif sound_4.status == STARTED and t >= (0.0 + (3.5)): #most of one frame period left
                sound_4.stop()  # stop the sound (if longer than duration)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineTimer.reset()  # if we abort early the non-slip timer needs reset
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in stimulus_4Components:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "stimulus_4"-------
        for thisComponent in stimulus_4Components:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                #### Write to tsv ####
                stimulus_4_save = [voice_file4_time,3.5,'voice_file',block_count+1,instruction_text,'','','','','',voice_file4,expInfo['date']]
                with open(tsvFile, "a",newline="") as f_tsv:
                    tsv_writer = csv.writer(f_tsv, delimiter = '\t')
                    tsv_writer.writerow(stimulus_4_save) # write the header
        thisExp.nextEntry()
    
    
        
    
        
    # set up handler to look after randomisation of conditions etc
    #trials = data.TrialHandler(nReps=2, method='sequential', 
    #trials = data.TrialHandler(nReps=1, method='sequential', #PILOT_TEST
    #    extraInfo=expInfo, originPath=None,
    #    trialList=[None],
    #    seed=None, name='trials')
    #thisExp.addLoop(trials)  # add the loop to the experiment
    #thisTrial = trials.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisTrial.rgb)
    #if thisTrial != None:
    #    for paramName in thisTrial.keys():
    #        exec('{} = thisTrial[paramName]'.format(paramName))
    
    
   # for thisTrial in trials:
    #    currentLoop = trials
        # abbreviate parameter names if possible (e.g. rgb = thisTrial.rgb)
     #   if thisTrial != None:
      #      for paramName in thisTrial.keys():
       #         exec('{} = thisTrial[paramName]'.format(paramName))
    
        
    #------Prepare to start Routine "rating"-------
    t = 0
    ratingClock.reset()  # clock 
    frameN = -1
    routineTimer.add(8.000000)
    ### Time for tsv ###
    rating_time=int(StartedTrialClock.getTime())
    # update component parameters for each repeat
    text_4.setText(question)
    murfi.update()
    stg_vector_all.append(murfi.FB_stg)
    smc_vector_all.append(murfi.FB_smc)
    #print"murfi update 3"
    # keep track of which components have finished
    ratingComponents = []
    ratingComponents.append(text_4)
    ratingComponents.append(rating)    
    for thisComponent in ratingComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
            

    #-------Start Routine "rating"-------
    continueRoutine = True
    rating.reset()
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = ratingClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *text_4* updates
        if t >= 0.0 and text_4.status == NOT_STARTED:
            # keep track of start time/frame for later
            text_4.tStart = t  # underestimates by a little under one frame
            text_4.frameNStart = frameN  # exact frame index
            text_4.setAutoDraw(True)
        elif text_4.status == STARTED and t >= (0.0 + (8.0)): #most of one frame period left
            text_4.setAutoDraw(False)
        
        #*rating* updates
        if t > 0.0:
            rating.draw()
            continueRoutine = rating.noResponse
            if rating.noResponse == True:
                #rating.response = rating.getRating()
                #rating.rt = rating.getRT()
                lastRating=rating.getHistory()[-1]
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineTimer.reset()  # if we abort early the non-slip timer needs reset
            lastRating=rs.getHistory()[-1]
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ratingComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "rating"-------
    for thisComponent in ratingComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
            #### Write to tsv ####
    rating_save = [rating_time,8,'rating',block_count+1,instruction_text,lastRating[0],lastRating[1],'','','',question,expInfo['date']]
    with open(tsvFile, "a",newline="") as f_tsv:
        tsv_writer = csv.writer(f_tsv, delimiter = '\t')
        tsv_writer.writerow(rating_save) # write the header
                
    # store data for block_order (TrialHandler)
    thisExp.addData('rating.response', rating.getRating())
    thisExp.addData('rating.rt', rating.getRT())
    thisExp.addData('lastRating',lastRating)
    thisExp.nextEntry()
    murfi.update()
    stg_vector_all.append(murfi.FB_stg)
    smc_vector_all.append(murfi.FB_smc)
    #print"murfi update 4"
    #push to datFile
    #datFile.write('%s\t%s\t%s\n'%(expInfo['subject[xxx]'],instruction_text,lastRating))
# completed 1 repeats of 'block_order'

    #------Prepare to start Routine "feedback"-------
    feedbackComponents = []
    feedbackComponents.append(image_8)
    for thisComponent in feedbackComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    t = 0
    feedbackClock.reset()  # clock 
    frameN = -1
    routineTimer.add(4.000000)
    ### Time for tsv ###
    feedback_time=int(StartedTrialClock.getTime())

    # update component parameters for each repeat
    if show_feedback==False:
        image_8.setOpacity(1)
    else:
        image_8.setOpacity(0)
        feedbackComponents.append(background_bar)
        feedbackComponents.append(zero_val_line)
        feedbackComponents.append(zero)
        feedbackComponents.append(top_text)
        feedbackComponents.append(bottom_text)
        if instruction_text=='listen to self':
            top_text.setText('listen to self')
            bottom_text.setText('ignore all sounds')
            self_other_conditions.append('listen to self')
            feedbackComponents.append(top_star)
        elif instruction_text=='ignore all sounds':
            top_text.setText('listen to self')
            bottom_text.setText('ignore all sounds')
            self_other_conditions.append('ignore all sounds')
            feedbackComponents.append(bottom_star)
        feedbackClock.reset()  # clock 
        frameN = 0
        routineTimer.add(4.000000)
        murfi.update()
        stg_vector_all.append(murfi.FB_stg)
        smc_vector_all.append(murfi.FB_smc)
        #print"murfi update 5"
        # update component parameters for each repeat
        if instruction_text=='ignore all sounds':
            top_text.setText('listen to self')
            bottom_text.setText('ignore all sounds')
            feedbackComponents.append('bottom_star')
            max=float(expInfo['max'])
            min=float(expInfo['min'])
            zero_val=float(expInfo['mid'])
            #zero_val=float(0)
            #zero_val=np.mean(float(expInfo['max']))-(float(expInfo['min']))
            index1= int(vector_indices[block_count][0])
            #print(index1,vector_indices[block_count])
            index2= int(vector_indices[block_count][1])
            stg_vector=np.array(murfi.FB_stg[index1:index2]) #original stg_vector=np.array(murfi.FB_stg[index1:index2])
            smc_vector=np.array(murfi.FB_smc[index1:index2])
            #print stg_vector,"stg_vector"
            #print smc_vector,"smc_vector"
            indices_to_remove=[]
            for idx,val in enumerate(stg_vector):
                if math.isnan(stg_vector[idx]): #or math.isnan(smc_vector[idx]):
                    indices_to_remove.append(idx)
            stg_vector_vector=np.delete(stg_vector,indices_to_remove)
            smc_vector_vector=np.delete(smc_vector,indices_to_remove)
            ### check for randomizaton and give feedback from either stg or smc###
            ### 1 treatment 0 control###
            if blinding == 1:
                #print("stg feedback treatment")
                fb_average=np.median(np.array(stg_vector_vector))
                stg_fb_average=np.median(np.array(stg_vector_vector))
                smc_fb_average=np.median(np.array(smc_vector_vector))
            else:
                #print("smc feedback control")
                fb_average=np.median(np.array(smc_vector_vector))
                stg_fb_average=np.median(np.array(stg_vector_vector))
                smc_fb_average=np.median(np.array(smc_vector_vector))
        elif instruction_text =='listen to self':
            top_text.setText('listen to self')
            bottom_text.setText('ignore all sounds')
            max=float(expInfo['max'])
            min=float(expInfo['min'])
            zero_val=float(expInfo['mid'])
            #zero_val=float(0)
            #zero_val=np.mean(float(expInfo['max']))-(float(expInfo['min']))
            feedbackComponents.append('top_star')
            index1= int(vector_indices[block_count][0])
            index2= int(vector_indices[block_count][1])
            stg_vector=np.array(murfi.FB_stg[index1:index2]) #original stg_vector=np.array(murfi.FB_stg[index1:index2])
            smc_vector=np.array(murfi.FB_smc[index1:index2])
            #print stg_vector,"stg_vector", len(murfi.FB_stg)
            #print smc_vector,"smc_vector",lwn(murfi.FB_smc)
            indices_to_remove=[]
            for idx,val in enumerate(stg_vector):
                if math.isnan(stg_vector[idx]): # or math.isnan(smc_vector[idx]):
                    indices_to_remove.append(idx)   
            stg_vector_vector=np.delete(stg_vector,indices_to_remove)
            smc_vector_vector=np.delete(smc_vector,indices_to_remove)
            ### check for randomizaton and give feedback from either stg or smc###
            ### 1 treatment 0 control###
            if blinding == 1:
                #print("stg feedback treatment")
                fb_average=np.median(np.array(stg_vector_vector))
                stg_fb_average=np.median(np.array(stg_vector_vector))
                smc_fb_average=np.median(np.array(smc_vector_vector))
            else:
                #print("smc feedback control")
                fb_average=np.median(np.array(smc_vector_vector))
                stg_fb_average=np.median(np.array(stg_vector_vector))
                smc_fb_average=np.median(np.array(smc_vector_vector))
        print (instruction_text)
        print (block_count)
        print (index1)
        print (index2)
        print ('stg:',stg_vector)
        print ('stg_average:',stg_fb_average)
        print ('smc:',smc_vector)
        print ('smc_average:',smc_fb_average)
        print ('fb:',fb_average) 
        #print smc_vector
        #print "nparray=",(np.array(stg_vector_vector)-np.array(smc_vector_vector))
        fb_stg=[]
        fb_smc=[]
        fb=[]
        #print fb
        if fb_average > max:
           fb = max
        elif fb_average< min:
           fb = min
        else:
           fb = fb_average
        rec=[]
        recs=[]
        
        recs=makeFBrecs(zero_val,fb,fillColor=None)
    # keep track of which components have finished

    
    #-------Start Routine "feedback"-------
    frameN=-1
    continueRoutine = True
    #murfi.update()
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = feedbackClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame

        if show_feedback==False:
            continue
        else:
            # *patch_2* updates
            if t >= 0.0:
                # keep track of start time/frame for later
                background_bar.setAutoDraw(True)
                zero_val_line.setAutoDraw(True)
                zero.setAutoDraw(True)
                top_text.setAutoDraw(True)
                bottom_text.setAutoDraw(True)
                #if instruction_text=='ignore all sounds':
                    #bottom_star.setAutoDraw(True)
                    
                #elif instruction_text=='listen to self':
                    #top_star.setAutoDraw(True)
                #if show_feedback==False:
                    #image_8.setAutoDraw(True)
            
                
            #elif patch_2.status == STARTED and t >= (0.0 + 4):
            elif t >=(0.0+4):
                background_bar.setAutoDraw(False)
                zero_val_line.setAutoDraw(False)
                zero.setAutoDraw(False)
                bottom_text.setAutoDraw(False)
                top_text.setAutoDraw(False)
                try:
                    #bottom_star.setAutoDraw(False)
                    #top_star.setAutoDraw(False)
                    image_8.setAutoDraw(False)
                except:
                    continue
            if frameN>=30:
                max_idx=30
            else:
                max_idx=floor(frameN)
        if show_feedback==False:
            continue
        else:
            if int(max_idx)>1:
                for idx in range(int(max_idx)):
                    recs[idx].setAutoDraw(True)
        
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineTimer.reset()  # if we abort early the non-slip timer needs reset
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in feedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
        if show_feedback==False:
            continue
        else:
            for idx in range(30): #original 30
                recs[idx].setAutoDraw(False)
                

                
        #-------Ending Routine "feedback"-------
        for thisComponent in feedbackComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
                
    #### Write to tsv ####
    if show_feedback==True:
        whatfeedbackColor=recs[idx].fillColor[0] #get color of feedback bar
        test_element = 1
        if whatfeedbackColor == test_element:
            feedbackColor='red'
        else:
            feedbackColor='green'
        
        feedback_save=[feedback_time,8,'feedback',block_count+1,instruction_text,'','','','',round(fb_average,3),feedbackColor,expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(feedback_save) # write the header
    else:
        nofeedback_save=[feedback_time,8,'nofeedback',block_count+1,instruction_text,'','','','','','+',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(nofeedback_save) # write the header
        
    
    #------Prepare to start Routine "fixation_2"-------
    t = 0
    fixation_2Clock.reset()  # clock 
    ### Time for tsv ###
    fixation_2_time=int(StartedTrialClock.getTime())
    frameN = -1
    if show_feedback==False:
        fixation_duration=15
    else:
        fixation_duration=11        
    routineTimer.add(fixation_duration)
    # update component parameters for each repeat
    block_count=block_count+1
    # keep track of which components have finished
    fixation_2Components = []
    fixation_2Components.append(image_fixation_2)
    for thisComponent in fixation_2Components:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "fixation_2"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = fixation_2Clock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *image_fixation_2* updates
        if t >= 0 and image_fixation_2.status == NOT_STARTED:
            # keep track of start time/frame for later
            image_fixation_2.tStart = t  # underestimates by a little under one frame
            image_fixation_2.frameNStart = frameN  # exact frame index
            image_fixation_2.setAutoDraw(True)
        elif image_fixation_2.status == STARTED and t >= (0 + (fixation_duration)): #most of one frame period left
            image_fixation_2.setAutoDraw(False)
        
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineTimer.reset()  # if we abort early the non-slip timer needs reset
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in fixation_2Components:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "fixation_2"-------
    for thisComponent in fixation_2Components:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    #### Write to tsv ####
    fixation_2_save=[fixation_2_time,fixation_duration,'fixation',block_count,instruction_text,'','','','','','+',expInfo['date']]
    with open(tsvFile, "a",newline="") as f_tsv:
        tsv_writer = csv.writer(f_tsv, delimiter = '\t')
        tsv_writer.writerow(fixation_2_save) # write the header
#---------Print max, med and min values to be used for feedback on Paul-------
index3=int(vector_indices[0][0])
index4=int(vector_indices[3][1])

all_vector=np.array(murfi.FB_stg[index3:index4])
all_vector_smc=np.array(murfi.FB_smc[index3:index4])

max=np.nanmax(np.array(all_vector))
med=np.median(np.array(all_vector))
min=np.nanmin(np.array(all_vector))

print ('max = ',("%.2f"%max))
print ('med = ',("%.2f"%med))
print ('min = ',("%.2f"%min))

#print('stg:',all_vector)
#print('smc:',all_vector_smc)

#------Prepare to start Routine "end"-------
t = 0
endClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
# keep track of which components have finished
endComponents = []
for thisComponent in endComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "end"-------
# Renaming previously exisiting files without numbers
if rename_files == 1:
    os.rename(stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.log' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']), stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events_attempt1.log' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']))
    os.rename(stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.tsv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']), stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events_attempt1.tsv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']))
    os.rename(selfref_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.psydat' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']), stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events_attempt1.psydat' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']))
    os.rename(selfref_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events.csv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']), stg_subjDir+os.sep+'sub-R33rtsz%s_%s_%s_%s_events_attempt1.csv' %(expInfo['subject[xxx]'], expInfo['session[1/2/3/4]'], expInfo['task[transferpre/transferpost]or[feedback]'],expInfo['run[xx]']))

continueRoutine = True
while continueRoutine:
    # get current time
    t = endClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in endComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()
    else:  # this Routine was not non-slip safe so reset non-slip timer
        routineTimer.reset()

#-------Ending Routine "end"-------
for thisComponent in endComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
ii=28.8
active_trial_count=26
num_intertrial_rows=0
intertrial_num=1

for i in range(0,len(all_vector)):
    ii+=exp_tr
    ii=round(ii,1)
    if active_trial_count in range(26,37):
        activation_save = [ii,exp_tr,'activation',1,feedback_trial_type[0],'n/a','n/a',all_vector[i],all_vector_smc[i],'n/a','murfi',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(activation_save) # write 
    elif active_trial_count in range(62,75):
        activation_save = [ii,exp_tr,'activation',2,feedback_trial_type[1],'n/a','n/a',all_vector[i],all_vector_smc[i],'n/a','murfi',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(activation_save) # write 
    elif active_trial_count in range(100,111):
        activation_save = [ii,exp_tr,'activation',3,feedback_trial_type[2],'n/a','n/a',all_vector[i],all_vector_smc[i],'n/a','murfi',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(activation_save) # write 
    elif active_trial_count in range(136,147):
        activation_save = [ii,exp_tr,'activation',4,feedback_trial_type[3],'n/a','n/a',all_vector[i],all_vector_smc[i],'n/a','murfi',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(activation_save) # write 
    else:
        activation_save = [ii,exp_tr,'activation','n/a','intertrial'+str(intertrial_num),'n/a','n/a',all_vector[i],all_vector_smc[i],'n/a','murfi',expInfo['date']]
        with open(tsvFile, "a",newline="") as f_tsv:
            tsv_writer = csv.writer(f_tsv, delimiter = '\t')
            tsv_writer.writerow(activation_save) # write active_trial_count+=1
            num_intertrial_rows += 1
            if num_intertrial_rows % 25 == 0:
                intertrial_num += 1
    active_trial_count+=1
#print(stg_vector_all)



#datFile.close()
win.close()
core.quit()
