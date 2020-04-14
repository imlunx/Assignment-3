#!/bin/bash
# Student Name  : Aaron Ng Wee Xuan
# Student Number: 10518970

Red="\033[31m"


getoneimage()
{
    #start loop and allow only acceptable inputs
    while :; do
        read -p "Which image do you want to download? " id
        #allow input from 1533 to 2042
        if (( $id >= 1533 && $id <= 2042 )); then
        break
        else 
        echo "Enter a number between 1533 and 2042!!"
        fi
    done
    #download specific image in quiet mode
    if ! wget -q https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/DSC0$id.jpg; then
        echo "Trying to download DSCO$id..."
        echo "Error 404: File Not Found"
        #else file can be downloaded
    else
    #retrieve the file size
    filesize=$(stat -c %s DSC0$id.jpg); 
    #format the filesize from bytes to kilobytes
    filesizekb=$(awk -v filesizekb=$filesize 'BEGIN { printf "%.2f\n", filesizekb / 1000 }')
    echo "Downloading DSC0$id, with the file name DSC0$id.jpg, with a file size of $filesizekb kb..." 
    echo "Download Complete"
    echo "PROGRAM FINISHED"
    #move downloaded images into the image directory
    mv DSC0$id.jpg ./images
    fi
    
 
}

getallimage()
{
    echo "Downloading all images..."
    #start loop while reading line by line from link.txt
    while read -r line; do
        #download image in quiet mode
        wget -q $line
        #read 8 characters from the 60th character
        #thereby getting name to download file
        local name=${line:60:8}
        #retrieve file size
        filesize=$(stat -c %s $name.jpg); 
        #format file size to kilobytes
        filesizekb=$(awk -v filesizekb=$filesize 'BEGIN { printf "%.2f\n", filesizekb / 1000 }')
        echo "Downloading $name, with the file name $name.jpg, with a file size of $filesizekb kb..." 
        echo -e "Download Complete\n"
    done < link.txt
    #move all downloaded image to image directory
    mv *.jpg ./images
    echo "PROGRAM FINISHED"
}

getimagerange()
{
    #start loop to check for errors
    while :; do
        #gather min and max input
        read -p "Which image do you want to start download from? " rangemin
        read -p "Which image do you want to end download at? " rangemax
        #allow input from 1533 to 2042 only
        if (( $rangemin < 1533 || $rangemin > 2042 )); then
        echo "Enter a number between 1533 and 2042!!"
        elif (( $rangemax < 1533 || $rangemax > 2042 )); then
        echo "Enter a number between 1533 and 2042!!"
        #check if minimum input is greater than maximum input
        #reject if error
        elif [ $rangemin -gt $rangemax ]; then
        echo "Minimum range must be greater then Maximumrange!"
        echo "Try Again!"
        else
        break
        fi
    done
    #loop from user's desired min and max
    for i in $(seq $rangemin $rangemax)
    do 
        #local var $i for downloading through the range
        local name=$i
        #if error due to file not found
        if ! wget -q https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/DSC0$i.jpg; then
        echo "Trying to download DSCO$name..."
        echo "Error 404: File Not Found"
        #else file can be downloaded
        else
        #retrieve filesize and convert to kilobytes
        filesize=$(stat -c %s DSC0$name.jpg); 
        filesizekb=$(awk -v filesizekb=$filesize 'BEGIN { printf "%.2f\n", filesizekb / 1000 }')
        echo "Downloading DSC0$name, with the file name DSC0$name.jpg, with a file size of $filesizekb kb..." 
        echo -e "Download Complete\n"
        #move downloaded images into image dir
        mv *.jpg ./images
        fi

    done
}

randomdownload()
{
    #set var to 0 for while loop
    times=0
    #request how many times user wants random downloads
    read -p "Enter how many pictures to be downloaded: " input
    #while loop to meet user's input
    while [ $times != $input ]; do
    #names of all available photo in given website
    #stored in Availablephoto.txt and shuffle to get random
    #name to download image
    local name=$(cat ./Availablephoto.txt | shuf -n 1)
    #download the randomised image
    wget -q https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$name.jpg
    #retrieve file size and convert to kilobytes
    filesize=$(stat -c %s $name.jpg); 
    filesizekb=$(awk -v filesizekb=$filesize 'BEGIN { printf "%.2f\n", filesizekb / 1000 }')
    echo "Downloading $name, with the file name $name.jpg, with a file size of $filesizekb kb..." 
    echo -e "Download Complete\n"
    #move all downloaded file into image dir
    mv *.jpg ./images
    #increase count so while loop will end
    ((times+=1))
    done
    echo "PROGRAM FINISHED"

}

show_menu()
{
    echo "Welcome to ECU image downloader!!"
    echo "================================="
    echo "What would you like to do today?"
    echo "1. Download a specific thumbnail"
    echo "2. Download ALL thumbnails"
    echo "3. Download images in a range"
    echo "4. Download a specified number of images randomly"
} 

downloaderprep()
{
    #run wget in quiet mode
    #save websites code into link1.txt
    wget -q -O link1.txt https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=152
    #grep needed links and save to link.txt
    grep -E "img src" link1.txt > link.txt
    #remove unneccasry words so that only link remains
    sed -i 's/<img src="//g; s/\" alt=.*>//g' link.txt
    #remove website's code
    rm link1.txt
    #make duplicate copy and remove unnecassary words
    #until name (i.e DSC0****) is left
    cp link.txt Availablephoto.txt
    sed -i 's/.*\/D/D/g; s/.jpg//g' Availablephoto.txt
    mkdir images
}

main()
{
    #start downloader prep and showmenu function
    downloaderprep
    show_menu
    #request user input
    read -p "Enter option here>> " input
    case $input in
        1 ) 
            getoneimage #first function
            ;;
            
        2 )
            getallimage #second function
            ;;

        3 ) 
            getimagerange #third function
            ;;

        4 )
            randomdownload #fourth function
            ;;

        *) 
            clear #in invalid input, redirect user to correct input
            echo -e "${Red}Please enter a correct input!!\e[0m"
            main
    esac
}

main
