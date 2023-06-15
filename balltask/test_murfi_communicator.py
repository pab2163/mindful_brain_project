import sys 
import time 
from murfi_activation_communicator import MurfiActivationCommunicator 

#change the roi names to whatever you have to test
roi_names = ['cen', 'dmn']
exp_tr=1.2 #seconds
print("murfi communicator running")
frame=0

def main(argv): 

     
    communicator = MurfiActivationCommunicator('192.168.2.5', 
                                               15001, 100, 
                                               roi_names) 
    while True: 
        communicator.update() 
        
        for roi in roi_names: 
            try:
                print(roi, communicator.get_roi_activation(roi))
            except: 
                print("waiting for: ",roi_names)
                pass 
 
        time.sleep(exp_tr) 
 
 
if __name__ == "__main__": 
    sys.exit(main(sys.argv)) 
 