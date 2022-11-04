#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.81.03), Wed 04 Feb 2015 11:22:15 AM EST
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
from murfi_activation_communicator import MurfiActivationCommunicator

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment 
expName = 'DMN_BallTask'  # from the Builder filename that created this script
expInfo = {'participant':'','session':'','No_of_ROIs':'2','Level_1_2_3':'1','No_repetitions':'1','Run_Time':'120','Scale_Factor':'5',}#Run_Time in seconds and direction  
BaseLineTime=30 #30 
exp_tr=1.2
murfi_FAKE=False
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
roi_number= str('%s') %(expInfo['No_of_ROIs'])
roi_number=int(roi_number)

RUN_TIME= str('%s') %(expInfo['Run_Time'])
RUN_TIME=int(RUN_TIME)
RUN_TIME=RUN_TIME

nReps=str('%s') %(expInfo['No_repetitions'])
nReps=int(nReps)

position_distance=expInfo['Level_1_2_3']
position_distance=int(position_distance)

scale_factor_z2pixels=expInfo['Scale_Factor']
scale_factor_z2pixels=int(scale_factor_z2pixels)


# Setup files for saving
if not os.path.isdir('data'):
    os.makedirs('data')  # if this fails (e.g. permissions) we will get error
filename = 'data' + os.path.sep + '%s_DMN_Feedback_%s_Scale%s' %(expInfo['participant'],expInfo['session'],expInfo['Scale_Factor'])
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

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
win = visual.Window(size=(1080,1080), fullscr=False, screen=1, allowGUI=False, allowStencil=False,#1024, 1024
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "instructions"
instructionsClock = core.Clock()
text = visual.TextStim(win=win, ori=0, name='text',
    text=u'Noting Practice\n\nIn this run you will see %s circles.\n\nThe upper yellow circle represents the brain process that corresponds to the Noting Practice.\
 \n\nTry to move the central dot into that circle!!\n\nTry to keep it there for 5 sec.\n\nIf you succeed, the circle will shrink and the dot will move back to the center.\
\n\nHow much can you shrink the circle?\n\nThis experiment will last 2 min.\n\n Press any button to start.' %int(roi_number),font=u'Arial',
    pos=[0, 0], height=0.06, wrapWidth=1.2,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "trigger"
triggerClock = core.Clock()
text_3 = visual.TextStim(win=win, ori=0, name='text_3',
    text=u'waiting for scanner',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=2,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "baseline"
baselineClock = core.Clock()
text_2 = visual.TextStim(win=win, ori=0, name='text_2',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.3, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "feedback"
feedbackClock = core.Clock()
import time
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import random
import csv
import math

 #murfi communicator
roi_names = ['cen', 'dmn']#, 'mpfc','wm']
# REPLACE THIS IP WITH THE MURFI COMPUTER'S IP 192.168.2.5
#communicator = MurfiActivationCommunicator('18.111.80.133',
#communicator = MurfiActivationCommunicator('18.189.76.118',
communicator = MurfiActivationCommunicator('192.168.2.5',
                                           15001, 210,
                                           roi_names,exp_tr,murfi_FAKE)
print ("murfi communicator ok")

text_4 = visual.TextStim(win=win, ori=0, name='text_4',
    text='default text',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-3.0)

#prepare the targets
colors=['yellow','blue','red','green','cyan','magenta','black','honeydew','indigo','maroon']
#drift_roi=['wm']
roi_names_list=['cen','dmn']
print (roi_names_list)
n_roi = roi_number
tau = 2 * np.pi
theta = np.zeros((n_roi))
for i in range(n_roi):
    theta[i] = (i * tau)/float(n_roi)

positions = np.exp((0-1j) * theta)
positions=positions*position_distance
# target_positions:
roi_pos = np.zeros((n_roi, 2))
for i in range(n_roi):
    #roi_pos[i, :] = [(np.imag(positions[i]))/3, (np.real(positions[i]))/3] #changes x y axis of circles
    roi_pos[i, :] = [(np.real(positions[i]))/3, (np.imag(positions[i]))/3]
    #print roi_pos
target_circles=[]
target_circles_id=[]
in_target_counter=[]
home=[]
for i in range(n_roi):
    roi_circle_i = visual.Circle(win, pos=(roi_pos[i, 1],roi_pos[i, 0]), radius=0.15,fillColor=None, lineColor=colors[i])
    #roi_circle_i.draw()
    target_circles.append(roi_circle_i)
    in_target_counter.append(0)
    print (in_target_counter)

starting_point = visual.Circle(win, pos=(0,0), radius=0.005,fillColor='white', lineColor='white')
home.append(starting_point)
#print roi_circle_i,roi_names_list[i], roi_circle_i.lineColor
#print targets

# Initialize components for Routine "finish"
finishClock = core.Clock()
text_5 = visual.TextStim(win=win, ori=0, name='text_5',
    text=u'thank you!',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

#------Prepare to start Routine "instructions"-------
t = 0
instructionsClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
key_resp_2 = event.BuilderKeyResponse()  # create an object of type KeyResponse
key_resp_2.status = NOT_STARTED
# keep track of which components have finished
instructionsComponents = []
instructionsComponents.append(text)
instructionsComponents.append(key_resp_2)
for thisComponent in instructionsComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "instructions"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = instructionsClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *text* updates
    if t >= 0.0 and text.status == NOT_STARTED:
        # keep track of start time/frame for later
        text.tStart = t  # underestimates by a little under one frame
        text.frameNStart = frameN  # exact frame index
        text.setAutoDraw(True)
    
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
        theseKeys = event.getKeys(keyList=['space','1','2'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            key_resp_2.keys = theseKeys[-1]  # just the last key pressed
            key_resp_2.rt = key_resp_2.clock.getTime()
            # a response ends the routine
            continueRoutine = False
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in instructionsComponents:
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

#-------Ending Routine "instructions"-------
for thisComponent in instructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp_2.keys in ['', [], None]:  # No response was made
   key_resp_2.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('key_resp_2.keys',key_resp_2.keys)
if key_resp_2.keys != None:  # we had a response
    thisExp.addData('key_resp_2.rt', key_resp_2.rt)
thisExp.nextEntry()

#------Prepare to start Routine "trigger"-------
t = 0
triggerClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
key_resp_3 = event.BuilderKeyResponse()  # create an object of type KeyResponse
key_resp_3.status = NOT_STARTED
# keep track of which components have finished
triggerComponents = []
triggerComponents.append(text_3)
triggerComponents.append(key_resp_3)
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
    
    # *text_3* updates
    if t >= 0.0 and text_3.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_3.tStart = t  # underestimates by a little under one frame
        text_3.frameNStart = frameN  # exact frame index
        text_3.setAutoDraw(True)
    
    # *key_resp_3* updates
    if t >= 0.0 and key_resp_3.status == NOT_STARTED:
        # keep track of start time/frame for later
        key_resp_3.tStart = t  # underestimates by a little under one frame
        key_resp_3.frameNStart = frameN  # exact frame index
        key_resp_3.status = STARTED
        # keyboard checking is just starting
        key_resp_3.clock.reset()  # now t=0
        event.clearEvents(eventType='keyboard')
    if key_resp_3.status == STARTED:
        theseKeys = event.getKeys(keyList=['num_add', 't','+','5'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            key_resp_3.keys = theseKeys[-1]  # just the last key pressed
            key_resp_3.rt = key_resp_3.clock.getTime()
            # a response ends the routine
            continueRoutine = False
    
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
if key_resp_3.keys in ['', [], None]:  # No response was made
   key_resp_3.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('key_resp_3.keys',key_resp_3.keys)
if key_resp_3.keys != None:  # we had a response
    thisExp.addData('key_resp_3.rt', key_resp_3.rt)
thisExp.nextEntry()

#------Prepare to start Routine "baseline"-------
t = 0
baselineClock.reset()  # clock 
frameN = -1
routineTimer.add(BaseLineTime)
# update component parameters for each repeat
# keep track of which components have finished
baselineComponents = []
baselineComponents.append(text_2)
for thisComponent in baselineComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "baseline"-------
continueRoutine = True
print("starting baseline")
while continueRoutine and routineTimer.getTime() > 0:
    # get current time
    communicator.update()
    t = baselineClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *text_2* updates
    if t >= 0.0 and text_2.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_2.tStart = t  # underestimates by a little under one frame
        text_2.frameNStart = frameN  # exact frame index
        text_2.setAutoDraw(True)
    if text_2.status == STARTED and t >= (0.0 + (BaseLineTime-win.monitorFramePeriod*0.75)): #most of one frame period left
        text_2.setAutoDraw(False)
    
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

#-------Ending Routine "baseline"-------
for thisComponent in baselineComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# set up handler to look after randomisation of conditions etc
trials = data.TrialHandler(nReps=nReps, method='random', 
    extraInfo=expInfo, originPath=None,
    trialList=[None],
    seed=None, name='trials')
thisExp.addLoop(trials)  # add the loop to the experiment
thisTrial = trials.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisTrial.rgb)
if thisTrial != None:
    for paramName in thisTrial.keys():
        exec('{} = thisTrial[paramName]'.format(paramName))

#prepare to start routine feedback
#create file to save DMN and CEN activity per TR 
for thisTrial in trials:
    currentLoop = trials
    # abbreviate parameter names if possible (e.g. rgb = thisTrial.rgb)
    if thisTrial != None:
        for paramName in thisTrial.keys():
            exec('{} = thisTrial[paramName]'.format(paramName))
     
    TargetCircleBlue_X=0   
    TargetCircleBlue_Y=0
    TargetCircle_blue = visual.Circle(win, 
                        pos=(TargetCircleBlue_X,TargetCircleBlue_Y), 
                        radius=0.03,
                        fillColor='white',
                        lineColor='white',#str(TargetColor_red_yellow_blue),
                        lineWidth=3)
    TargetColor_red_yellow_blue= str('white') 
    #TargetCircle_blue.lineColor=str(TargetColor_red_yellow_blue)
    #print "The color is now: ",TargetColor_red_yellow_blue

    #------Prepare to start Routine "feedback"-------
    t = 0
    feedbackClock.reset()  # clock 
    frameN = -1
    # update component parameters for each repeat
    subject_key_target = event.BuilderKeyResponse()  # create an object of type KeyResponse
    subject_key_target.status = NOT_STARTED
    subject_key_reset = event.BuilderKeyResponse()  # create an object of type KeyResponse
    subject_key_reset.status = NOT_STARTED
    routineTimer.add(RUN_TIME)
    
    frame = 1
    dmn_feedback = []
    #mpfc_feedback = []
    cen_feedback = []
    dmn_mpfc_feedback=[]
    mpfc_cen_feedback=[]
    wm_feedback = []
    times = []
    
    #-------Start Routine "feedback"-------
    activity=0
    out_of_bounds=position_distance*0.4
    for i in range(n_roi):
        activity_i=0
    continueRoutine = True
    
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = feedbackClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *subject_key_target* updates
        if t >= 0.0 and subject_key_target.status == NOT_STARTED:
            # keep track of start time/frame for later
            subject_key_target.tStart = t  # underestimates by a little under one frame
            subject_key_target.frameNStart = frameN  # exact frame index
            subject_key_target.status = STARTED
            # keyboard checking is just starting
            subject_key_target.clock.reset()  # now t=0
            event.clearEvents(eventType='keyboard')
        if subject_key_target.status == STARTED:
            theseKeys = event.getKeys(keyList=['1', '2', '3', '4'])
            theseKeys_num=theseKeys
            
            #print theseKeys_num, TargetColor_red_yellow_blue
            
            if '4' in theseKeys:
                TargetCircleBlue_X=0
                TargetCircleBlue_Y=0 
            elif '1' in theseKeys:
                TargetColor_red_yellow_blue= str('blue') 
                TargetCircle_blue.lineColor=str(TargetColor_red_yellow_blue)
                print ("The color is still: ",TargetColor_red_yellow_blue)
            
            elif '2' in theseKeys:
                TargetColor_red_yellow_blue= str('yellow') 
                TargetCircle_blue.lineColor=str(TargetColor_red_yellow_blue)
                print ("The color is now: ",TargetColor_red_yellow_blue)
          
            elif '3' in theseKeys:
                TargetColor_red_yellow_blue= str('red') 
                TargetCircle_blue.lineColor=str(TargetColor_red_yellow_blue)
                print ("The color is now: ",TargetColor_red_yellow_blue)
            # check for quit:
            if "escape" in theseKeys:
                endExpNow = True
            if len(theseKeys) > 0:  # at least one key was pressed
                subject_key_target.keys = theseKeys[-1]  # just the last key pressed
                subject_key_target.rt = subject_key_target.clock.getTime()
            
        communicator.update()
        
        roi_raw_activations=[]
        for i in range(n_roi):
            roi_raw_i=communicator.get_roi_activation(roi_names_list[i], frame)
            roi_raw_activations.append(roi_raw_i)
        #drift_roi_raw=communicator.get_roi_activation(drift_roi[0], frame)
        
        """pcc = communicator.get_roi_activation('pcc', frame)
        mpfc = communicator.get_roi_activation('mpfc', frame)
        dlpfc = communicator.get_roi_activation('dlpfc', frame)
        wm = communicator.get_roi_activation('wm', frame)"""
        
        if roi_raw_activations[0] ==0: #and roi_raw_activations[0]==0:
            #win.close()
            print ("let's begin feedback")
           

        elif roi_raw_activations[0] != roi_raw_activations[0] or roi_raw_activations[0] != roi_raw_activations[0]:
            print ("began baseline")
            continue
        
        roi_activities=[]
        
        for i in range(n_roi):
            target_roi_i=(roi_raw_activations[i])#-drift_roi_raw) include this if wm mask is used to substract activity
            roi_activities.append(target_roi_i)
        """target_pcc=(pcc-wm)
        target_mpfc=(mpfc-wm)
        target_dlpfc=(dlpfc-wm)"""
        #print "roi actitivities",roi_activities
        print ("got feedback at time : ", frame, roi_raw_activations, roi_names_list)
     
        
  
        
        #print frame, "PCC= ",roi_activities[0], "MPFC= ",roi_activities[1], "DLPFC= ", roi_activities[2]
        
        #test for one direction unmark this
        #roi_activities[1]=roi_activities[1]+1
        
        """print "di at time %d: %f, %f, %f, %f" % (frame, pcc, mpfc,dlpfc,wm)
        print frame, "PCC= ",target_pcc, "MPFC= ",target_mpfc, "DLPFC= ", target_dlpfc
        roi_activities=(target_pcc,target_mpfc,target_dlpfc)"""
        
        #print "roi activities", roi_activities
        cursor_position = np.dot(activity, positions)
        #print frame, cursor_position
        #print 'max_roi: ',max(roi_activities),'index:',roi_activities.index(max(roi_activities))

        def in_circle(center_x, center_y, radius, x, y):
            square_dist = (center_x - x) ** 2 + (center_y - y) ** 2
            return square_dist <= radius ** 2
        
        for i in range(n_roi):
            
            if in_circle(0,0,(out_of_bounds),TargetCircle_blue.pos[1],TargetCircle_blue.pos[0])==True:
                #print "fareway",in_circle(0,0,0.9,TargetCircle_blue.pos[0],TargetCircle_blue.pos[1])
                pass
            else:
                #print "out of bounds"
                TargetCircleBlue_X=0
                TargetCircleBlue_Y=0
                TargetCircle_blue.pos=(TargetCircleBlue_X,TargetCircleBlue_Y)
            
            if roi_activities.index(np.nanmax(roi_activities))==i and np.nanmean(roi_activities)!=0:
                
                #activity=abs((np.max(roi_activities))/5)
                activity=abs(np.nanmax(roi_activities)-(np.nanmin(roi_activities)))/10
                #print "activity_dif",activity_diff
                print ("activity",activity, " roi_activities",roi_activities)
                cursor_position = np.dot(positions[i], activity)
                
                TargetCircleBlue_Y=TargetCircleBlue_Y+ (np.real(cursor_position) * scale_factor_z2pixels/20) #
                TargetCircleBlue_X=TargetCircleBlue_X+ (np.imag(cursor_position) * scale_factor_z2pixels/20)
                print ("direction -->", roi_names_list[i])
                roi_write=roi_names_list[i]
                
                TargetCircle_blue.pos=(TargetCircleBlue_X,TargetCircleBlue_Y)
                #print "dir position:",np.real(positions[i])
                #print frame,"direction: ",roi_names_list[i], "in circle:", in_circle(target_circles[i].pos[0],target_circles[i].pos[1],target_circles[i].radius,TargetCircle_blue.pos[0],TargetCircle_blue.pos[1])
                if in_circle(target_circles[i].pos[0],target_circles[i].pos[1],target_circles[i].radius,TargetCircle_blue.pos[0],TargetCircle_blue.pos[1]) ==True:
                    #print traget_circles_clock[i].getTime()
                    in_target_counter[i]=in_target_counter[i]+1
                    
                else:
                    continue
                if in_target_counter[i]==5:
                    TargetCircleBlue_X=0
                    TargetCircleBlue_Y=0
                    #print "cero"
                    #TargetCircle_blue.pos=(TargetCircleBlue_X,TargetCircleBlue_Y)
                    target_circles[i].radius=0.1
                    continue
                elif in_target_counter[i]==10:
                    TargetCircleBlue_X=0
                    TargetCircleBlue_Y=0
                    #print "cero"
                    #TargetCircle_blue.pos=(TargetCircleBlue_X,TargetCircleBlue_Y)
                    target_circles[i].radius=0.05
                    continue
                elif in_target_counter[i]==11:
                    
                    #print "cero"
                    #TargetCircle_blue.pos=(TargetCircleBlue_X,TargetCircleBlue_Y)
                    target_circles[i].pos[0]=(target_circles[i].pos[0]*1.25)
                    target_circles[i].pos[1]=(target_circles[i].pos[1]*1.25)
                    out_of_bounds=out_of_bounds*2
                    TargetCircleBlue_X=0
                    TargetCircleBlue_Y=0
                    target_circles[i].radius=0.033
                    continue
                    
                else:
                    continue
                
                # print frame,"direction: ",roi_names_list[i],'roi_pos:',target_circles[i].pos[0],target_circles[i].pos[1], "position:", TargetCircle_blue.pos
                for i in range(n_roi):
                    target_circles[i].draw()
                TargetCircle_blue.draw()
                         
            #win.flip()
            #core.wait(1)
            else:
                continue
                
    
        #Draw the Target
        
        times.append(frame)
        frame += 1
        
        for i in range(n_roi):
            target_circles[i].draw()
            print (roi_names_list[i],"hits:",in_target_counter[i])
        TargetCircle_blue.draw()#,home[0].draw()
        core.wait(1)
        #print"wait 1"
        win.flip()

        #Write roi_activity to csv
        if frame <25:
            with open(filename+'_ROI_activity_baseline.csv', 'a') as csvfile:
                    stim_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
              
                    stim_writer.writerow(['frame','direction',roi_names[0],roi_names[1]])
        elif frame >=25:
            with open(filename+'_ROI_activity_feedback.csv', 'a') as csvfile:
                    stim_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
              
                    stim_writer.writerow([frame,roi_write,roi_raw_activations[0],roi_raw_activations[1]])
                    print ("direction write:",   roi_write)

    
          
    #------Prepare to start Routine "baseline"-------
    t = 0
    baselineClock.reset()  # clock 
    frameN = -1
    routineTimer.add(1.00000)
    # update component parameters for each repeat
    # keep track of which components have finished
    baselineComponents = []
    baselineComponents.append(text_2)
    for thisComponent in baselineComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "baseline"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = baselineClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
    
        # *text_2* updates
        if t >= 0.0 and text_2.status == NOT_STARTED:
            # keep track of start time/frame for later
            text_2.tStart = t  # underestimates by a little under one frame
            text_2.frameNStart = frameN  # exact frame index
            text_2.setAutoDraw(True)
        if text_2.status == STARTED and t >= (0.0 + (1-win.monitorFramePeriod*0.75)): #most of one frame period left
            text_2.setAutoDraw(False)
    
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
    
    #-------Ending Routine "baseline"-------
    for thisComponent in baselineComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
  
 
#------Prepare to start Routine "finish"-------
t = 0
finishClock.reset()  # clock 
frameN = -1
routineTimer.add(5.000000)
# update component parameters for each repeat
# keep track of which components have finished
finishComponents = []
finishComponents.append(text_5)
for thisComponent in finishComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "finish"-------
continueRoutine = True
while continueRoutine and routineTimer.getTime() > 0:
    # get current time
    t = finishClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *text_5* updates
    if t >= 0.0 and text_5.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_5.tStart = t  # underestimates by a little under one frame
        text_5.frameNStart = frameN  # exact frame index
        text_5.setAutoDraw(True)
    if text_5.status == STARTED and t >= (0.0 + (5-win.monitorFramePeriod*0.75)): #most of one frame period left
        text_5.setAutoDraw(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineTimer.reset()  # if we abort early the non-slip timer needs reset
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in finishComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "finish"-------
for thisComponent in finishComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

win.close()
core.quit()
