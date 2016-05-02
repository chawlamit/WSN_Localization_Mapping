/*									tab:4
 * Copyright (c) 2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * Java-side application for testing serial port communication.
 * 
 *
 * @author Phil Levis <pal@cs.berkeley.edu>
 * @date August 12 2005
 */

import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

import java.net.*;
import java.io.*;

import java.util.*;

class Request {
    int roomId;
    int nodeId;
    int groupId;
    long time;
    int quad;
  Request(int roomId,int nodeId, int groupId, long time, int quad) {
    this.roomId = roomId;
    this.nodeId = nodeId;
    this.groupId = groupId;
    this.time = time;
    this.quad = quad;
    }

  }

public class TestSerial implements MessageListener, Runnable {

  private MoteIF moteIF;
  
  private ArrayList<Request> que = new ArrayList<Request>();
  static float roomX = 10;  // room dimensions
  static float roomY = 10;
  
  public TestSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new TestSerialMsg(), this);
  }

  public void start() {
  }

  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;
    System.out.println("To string - " + msg.toString());

    int quad = msg.get_quad();
    int nodeId = msg.get_nodeId();
    nodeId = nodeId - 9;  //because our node id starts from 10
    // float x = msg.get_loc_x();
    // float y = msg.get_loc_y();
    
    // if (x < roomX/2) {
    //   if (y < roomY/2) {
    //     quad = 1;
    //   }

    //   else {
    //     quad = 3;
    //   }
    // }
    
    // else{
    //  if (y < roomY/2) {
    //     quad = 2;
    //   }

    //   else {
    //     quad = 4;
    //   }
    // }



    Request r = new Request(msg.get_roomId(), nodeId, 1, System.currentTimeMillis()/1000, quad);
    que.add(r);

  }
  
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }

  public void run(){
    System.out.println("started thread");
    String url = "http://neaproject.au-syd.mybluemix.net/data";
    while (true){
    // System.out.println("Que size :" + this.que.size());
    try {
      Thread.sleep(1000);                 //1000 milliseconds is one second.
    } catch(InterruptedException ex) {
      Thread.currentThread().interrupt();
    }

      if(que.size()>0){
           System.out.println("inside if");

        String query = "roomID="+que.get(0).roomId + "&" +
                     "nodeID="+que.get(0).nodeId + "&" +
                     "groupID="+que.get(0).groupId + "&" +
                     "time="+que.get(0).time + "&" +
                     "quadNO="+que.get(0).quad;
        // URLConnection conn = url.openConnection();
       try {
            System.out.println("going to send now");
                
        URLConnection connection = new URL(url + "?" + query).openConnection();
        // connection.setRequestProperty("Accept-Charset", charset);
        InputStream response = connection.getInputStream();

        Scanner scanner = new Scanner(response);
        String responseBody = scanner.useDelimiter("\\A").next();
        System.out.println(responseBody);
        }
        catch (Exception e) {
          System.out.println("Exception : " + e);
        }
        que.remove(0);
        
      }  
    }  
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    System.out.println("Source = " + source);
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    TestSerial serial = new TestSerial(mif);
    Thread t1 = new Thread(serial);
    t1.start();
    serial.start();


  }


}
