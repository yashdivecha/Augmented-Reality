
%% Setting up the video parameters

    vid = videoinput('winvideo', 1,'YUY2_800x600');
    set(vid,'FramesPerTrigger',1);
    set(vid,'TriggerRepeat',Inf);
    triggerconfig(vid, 'Manual');
    vid.ReturnedColorspace = 'rgb';
    
    %% Starting the video and previewing it for the purpose of triggers

    start(vid);
    preview(vid);
    %% Setting initial parameters and reading in the file to augment
    
    flag=0;
    x_c=0;
    y_c=0;
    J=imread('tryspecs4.jpg');
    
    %% The main loop starts here
    
    for i=1:1:70
        
    % trigger video:
        trigger(vid);
    
        %% getting the image from the trigger and starting the preprocessing
        
        IM = (getdata(vid,1,'uint8'));
        I = rgb2gray(IM);
        threshold = graythresh(I);
        bw = im2bw(I,threshold);
        bw = bwareaopen(bw,30);
        
        se = strel('disk',2);
        bw = imclose(bw,se);

        bw = imfill(bw,'holes');
        
        [B,L] = bwboundaries(bw,'noholes');
        
        stats = regionprops(L,'Area','Centroid');
        %% Setting a threshold for metric... anything close to 1.
        
        threshold = 0.80;
        
       
     
        %% Here the actual detection of marker takes place
       
        for k = 1:length(B)
    
             flag=0;
             
  % obtain (X,Y) boundary coordinates corresponding to label 'k'
             boundary = B{k};

  % compute a simple estimate of the object's perimeter
             delta_sq = diff(boundary).^2;
             perimeter = sum(sqrt(sum(delta_sq,2)));

  % obtain the area calculation corresponding to label 'k'
             area = stats(k).Area;

  % compute the roundness metric
             metric = 4*pi*area/perimeter^2;

  % display the results
             metric_string = sprintf('%2.2f',metric);

  
  % Checking if metric satisfies the condition
                if metric > threshold
                    
                    centroid = stats(k).Centroid;    
                    rcen1=round(centroid(1));
                    rcen2=round(centroid(2));
                    cent_1 = sprintf('%2.2f',centroid(1));
                    cent_2 = sprintf('%2.2f',centroid(2));
                    HLwhite=0;
                    HRwhite=0;
                    iR=rcen1;
                    iL=rcen1;
                         while(true)    
                            if(impixel(bw,iR,rcen2)==1)
                                 HRwhite=HRwhite+1;
                                 HLwhite=HLwhite+1;
                                 iR=iR+1;
                                 iL=iL-1;
                            else
                                 break;
                            end
   
        
                         end
    
 
    
%% If conditions are satisfied then start Augmenting
    
                         if(HLwhite-HRwhite<5 && HLwhite>20)
                            
                             x_c=round(centroid(1));
                             y_c=round(centroid(2));
                             flag=1;                       
                             in=y_c-250;
                             jn=x_c;
                             t_jn=x_c;
                             t_in=y_c-250;
                             
                                for it=1:1:50
                                    for jt=1:1:144
                                        
                                        if J(it,jt,:)<20
                                            IM(in,jn,:)=J(it,jt,:);
                                   else if J(it,jt,:)<250
                                            IM(in,jn,:)=IM(in,jn,:)+J(it,jt,:);
                                       end
                                       end
                                
                                        jn=jn+1;
                                
                                        if(jn==t_jn+144)
                                            jn=t_jn;
                                            in=in+1;
                                        end
                
                                    end
                                end    
                            
                     
                             
                             
                         end
                        
                    
%% Display the Real time video with the Augmented images

                        imshow(IM); 
                        
                        if flag==1
                            text(x_c,y_c,'marker is here');
                        end
        
                         
                end
    
                           if(flag==1)
                              break;
                           end

        end
     end
  
    stop(vid)
    delete(vid)