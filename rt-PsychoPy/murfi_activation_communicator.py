"""Class to retreive and store ROI activations from murfi. See the
accompanying test_murfi_communicator.py for example usage.
"""

import socket
import re
import random
import time
volumes_count=0
class MurfiActivationCommunicator:
    
    def __init__(self, ip, port, num_trs, roi_names, exp_tr,fake):

        self._ip = ip
        self._port = port
        self._num_trs = num_trs
        self._exp_tr = exp_tr
        self._fake = fake
        self._rois_fake= roi_names
        self._rois = {}
        for roi_name in roi_names:
            self._rois[roi_name] = {
                'last_tr': -1,
                'activation': [float('NaN')] * self._num_trs
            }

        self._roi_query = \
            '<?xml version="1.0" encoding="UTF-8"?>' \
            '<info>' \
            '<get dataid=":*:*:*:__TR__:*:*:roi-weightedave:__ROI__:"></get>' \
            '</info>\n'
        #print("communicator ip:",self._ip)
        #print("communicator port:",self._port)
        #print("communicator num_trs:",self._num_trs)
        #print("communicator exp_tr:",self._exp_tr)
        #print("communicator fake:",self._fake)

    def _send(self, mesg):
        if not self._fake:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            #print("sock:",sock)
            sock.connect((self._ip, self._port))
            #print("sock.connect:",sock.connect((self._ip, self._port)))
            #print("sock.sendall:",sock.sendall(mesg.encode('utf-8')))
            sock.sendall(mesg.encode('utf-8'))
            resp = sock.recv(4096)
            #resp = resp.encode()
            #print("resp:",type(resp))
            #print(type(resp))
            #print("volume #",volumes_count,resp)
            sock.close()
            return resp
            
        else:
            for roi_name in self._rois_fake:
                self._rois[roi_name] = str(random.gauss(0,1))
                resp = self._rois[roi_name].encode()
                time.sleep(self._exp_tr)
                #print(type(resp))
                print( "::::DEBUG MODE.RUNNING MURFI SIMULATOR::::")
                print("volume #",volumes_count,roi_name,resp)
                return resp #str(random.gauss(0,1))

    def _ask_for_roi_activation(self, roi_name, tr):
        if tr >= self._num_trs:
            raise ValueError("Requested TR out of bounds")
            return

        to_send = self._roi_query
        to_send = to_send.replace('__TR__', str(tr + 1))
        to_send = to_send.replace('__ROI__', roi_name)
        resp = self._send(to_send)
        #re.sub needs bytes not strings, here we change that
        first_re="<.*?>"
        first_re = first_re.encode()
        second_re=""
        second_re = second_re.encode()
        #now we can send
        stripped = re.sub(first_re, second_re, resp)
        
        
        try:
            num = float(stripped)
        except ValueError:
            num = float('nan')

        return num

    def get_roi_activation(self, roi_name, tr=None):
        if roi_name not in self._rois:
            raise ValueError("No such roi %s" % roi_name)

        if tr is None:
            tr = self._rois[roi_name]['last_tr']
            print(tr)

        if tr < 0 or tr >= self._num_trs:
            raise ValueError("Requested TR out of bounds (tr=%s" % tr)

        return self._rois[roi_name]['activation'][tr]

    def update(self):
        for roi_name, roi in self._rois.items():
            if roi['last_tr'] >= self._num_trs:
                continue

            act = self._ask_for_roi_activation(roi_name, roi['last_tr'] + 1)
            #print(act)
            while act == act:
                roi['last_tr'] += 1
                roi['activation'][roi['last_tr']] = act
                act = self._ask_for_roi_activation(roi_name, roi['last_tr'] + 1)
