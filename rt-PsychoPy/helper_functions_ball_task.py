from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import time
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import random
import csv
import math
import pandas as pd
import sys
import threading
import subprocess
import shlex
import locale


# function to check whether ball is in a given circle
def in_circle(center_x, center_y, radius, x, y):
    square_dist = (center_x - x) ** 2 + (center_y - y) ** 2
    return square_dist <= radius ** 2


# checks if ball has gone out of bounds above/below the middle of a circle
def further_than_circles(position, circle_center, ball_center):
    # if ball is above center of top circle
    if position == 0:
        further = ball_center > circle_center
    # if ball is below center of bottom circle
    elif position == 1:
        further = ball_center < circle_center
    return(further)


def wait_for_keypress(key_list:list):
    continueRoutine = True
    while continueRoutine:
        theseKeys = event.getKeys(keyList=key_list)
        if len(theseKeys) > 0:  # at least one key was pressed
                # a response ends the routine
                continueRoutine = False


def run_instructions(instruct_text):
    instruct_text.draw()
    win.flip()
    wait_for_keypress(['space'])


def calculate_ball_position(circle_reference_position, activation, ball_x_position, ball_y_position, outlier):
    # New cursor position (of ball) will be dot product of position (negative if DMN, positive if CEN) and activity (always positive)
    cursor_position = np.dot(circle_reference_position, activation)

    # only update ball position if the PDA metric isn't an outlier
    if not outlier:
        # The position of the target circle cumulatively adds the scaled cursor position on each frame
        ball_y_position =ball_y_position+ (np.real(cursor_position) * (scale_factor_z2pixels/internal_scaler) / tr_to_frame_ratio) 
        ball_x_position=ball_x_position+ (np.imag(cursor_position) * scale_factor_z2pixels/internal_scaler / tr_to_frame_ratio )
    
    ball_position=(ball_x_position,ball_y_position)
    return(ball_position)    

def run_slider(question_text='Default Text', left_label='left', right_label='right'):
    slider_question = visual.TextStim(win=win, ori=0, name='text',
        text=question_text, font=u'Arial',
        pos=[0, 0.2], height=0.06, wrapWidth=1.2,
        color=u'white', colorSpace='rgb', opacity=1,
        depth=0.0)

    vas = visual.Slider(win,
                size=(0.85, 0.1),
                ticks=(1, 9),
                labels=(left_label, right_label),
                granularity=1,
                color='white',
                fillColor='white',
                font=u'Arial')

    event.clearEvents('keyboard')
    vas.markerPos = 5
    vas.draw()
    slider_question.draw()
    win.flip()
    continueRoutine = True
    while continueRoutine:
        keys = event.getKeys(keyList=['2', '3', '4'])
        if len(keys):
            if '2' in keys:
                vas.markerPos = vas.markerPos - 1
            elif '3' in keys:
                vas.markerPos = vas.markerPos  + 1 
            elif '4' in keys:
                vas.rating=vas.markerPos
                continueRoutine=False
            vas.draw()
            slider_question.draw()
            win.flip()
            print(keys)

    print(f'Rating: {vas.rating}, RT: {vas.rt}')
    with open(run_questions_file, 'a') as csvfile:
            stim_writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            stim_writer.writerow([expInfo['participant'], expInfo['run'], expInfo['feedback_on'],
                                  question_text, vas.rating, vas.rt])   

    
    return(vas.rating)

def quit_psychopy():
    """Close everything and exit nicely (ending the experiment)
    """
    # pygame.quit()  # safe even if pygame was never initialised
    logging.flush()

    # properly shutdown ioHub server
    from psychopy.iohub.client import ioHubConnection

    if ioHubConnection.ACTIVE_CONNECTION:
        ioHubConnection.ACTIVE_CONNECTION.quit()

    for thisThread in threading.enumerate():
        if hasattr(thisThread, 'stop') and hasattr(thisThread, 'running'):
            # this is one of our event threads - kill it and wait for success
            thisThread.stop()
            while thisThread.running == 0:
                pass  # wait until it has properly finished polling

def start_next_run():
    # Set variables for the next run
    if expInfo['run'] == '1' and expInfo['feedback_on'] == 'No Feedback':
        next_run =1
        next_feedback= 'Feedback'
    elif expInfo['run'] == '2' and expInfo['feedback_on'] == 'No Feedback': 
        next_run =6
        next_feedback = 'Feedback'
    elif expInfo['run'] == '5':
        next_run =2
        next_feedback='No'
    elif expInfo['run'] == '10':
        next_run =3
        next_feedback='No'
    else:
        next_run = int(expInfo['run']) + 1
        next_feedback='Feedback'

    next_participant=expInfo['participant']
    anchor = expInfo['anchor']
    next_feedback_condition = expInfo['feedback_condition']

    # Shut down psychopy before starting next run
    quit_psychopy()

    # Start next run!
    if expInfo['feedback_condition']=='15min':
        if next_run < 6:
            os.system(f"python ball_task.py {next_participant} {next_run} {next_feedback} {next_feedback_condition} {anchor}")
    elif expInfo['feedback_condition']=='30min':
        if not (expInfo['feedback_on'] == 'No Feedback' and int(expInfo['run'])==3):
            os.system(f"python ball_task.py {next_participant} {next_run} {next_feedback} {next_feedback_condition} {anchor}")


# INSTRUCTION SLIDE TEXT
no_feedback_run1_text = f"Next, you will get to continue the Mental Noting practice you just learned about.\
    \n\nBefore, you mentioned using your {expInfo['anchor']} as an anchor for your Noting Practice. \
Try to continue using this as your anchor but it is also okay to switch to a different part of your body.\
\n\nYou’ll see 2 circles and a white ball in the middle on the screen, but they won’t move around for now."

ready_text="You’ll see the cross (+) on the screen for 30 seconds at the start. \
Whenever you see the cross, please don’t practice Noting – just relax.\
\n\nOnce you see the circles appear, please start the Noting practice. \
This practice will last 2 min. Press any button to start." 

feedback_run1_text1 = "Great job! Now, you’ll get to continue your Mental Noting with some feedback based on your brain to help your practice. \
\n\nIn this run, you’ll see 2 circles and a white ball in the middle. \
When the white ball moves up towards the top circle, this corresponds to the Noting practice.\
\nIf the ball gets into either of the circles, it will move back to the center. \
\n\nTry to keep the ball moving up towards the top circle! How many times can you get to the top?"

feedback_run1_text2 = "Try not focusing or paying too much attention on the ball movement since this can be distracting from the actual Noting Practice.\
\n\nRather, really try focusing on your sensations from moment to moment, noting them silently in your mind \
and just check in on the screen from time to time to see where the ball is going." 

feedback_later_runs_text = "Great job! Next, you’ll get to practice Noting for another two minutes with more feedback from the ball. \
\n\nRemember to relax when the cross (+) is on the screen and once the circles appear try to keep the ball moving up towards the top circle! \
\n\nThis practice will last 2 min. Press any button to start."

no_feedback_later_runs_text = "Great job! Next, you’ll get to practice Noting for another two minutes. \
\nThis time the ball and circles will not move, so you don’t need to check them."