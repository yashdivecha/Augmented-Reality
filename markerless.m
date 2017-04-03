%% Setting the video parameters

    vid = videoinput('winvideo', 1,'YUY2_800x600');
    set(vid,'FramesPerTrigger',1);
    set(vid,'TriggerRepeat',Inf);
    triggerconfig(vid, 'Manual');
    vid.ReturnedColorspace = 'rgb';

%% Starting the video

    start(vid);
    
%% Reading the Augmenting Image
    
    spec=imread('tryspecs41.jpg');
%% Staring the main Loop for continuous triggers
 
    for i=1:1:30
        
        % triggers video on every loop
        trigger(vid);
        
        % acquire the data from the triggers
        IM = (getdata(vid,1,'uint8'));
        
        % adjusting the size of the window
        IM_r=imcrop(IM,[255 254 600 600]);


        % Create a detector object using the vision class
        % This uses the Viola Jones Algorithm for Face Detection
        faceDetector = vision.CascadeObjectDetector; 


        % Detect faces and create a bounding box around the detected face.
        bbox = step(faceDetector, IM_r); 


        % This is where we check whether face is detected or not.
        TF=isempty(bbox);



        %check if TF is full ... If it is then face is detected ... start
        %the Augmenting of Specs
        
        if(TF==0)
            st_x=bbox(1,1)+13;   %Most Important part of module to locate the eyes
            st_y=bbox(1,2)+45;
            t_x=st_x+7;
            t_y=st_y+45;

   
        % The Augmentation Module
            for in=1:1:50
                for jn=1:1:144
                    if spec(in,jn,:)<20
                      IM_r(st_y,st_x,:)=spec(in,jn,:);
                    end
                             if spec(in,jn,:)<253
                      IM_r(st_y,st_x,:)=IM_r(st_y,st_x,:)+spec(in,jn,:);
                             end
                    
                    st_x=st_x+1;
                    if(st_x==t_x+144)
                        st_x=t_x;
                        st_y=st_y+1;

                    end
                end
            end
         
        end
        
        
        %Displaying the LIVE Video Stream with the Augmented Image.
        imshow(IM_r), title('Please sit comfortably at a sufficient distance as instructed'); 

    end
    
    stop(vid);
    delete(vid);