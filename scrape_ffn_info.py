#
#   This script will get fanfiction info (title, author, summary, etc.) by scraping it
#   
#
from lxml import html, etree
import requests, time, csv, math, random, os.path

# main function
def main():

    first_page = 22			# Page to start from
    pages_to_parse = 5   # Number of pages to parse
    # last_page = 29075      # Last page as of Mar 2017 (for reference) 
    pause_length = 1.5 		# Seconds between page requests
    allowed_fails = 3 		# Number of times requests can fail before quitting
    base_url = 'https://www.fanfiction.net/book/Harry-Potter/?&srt=2&r=10' #Sorted by publish date and no rating restriction
    fic_info = []
    group_fail = 0
    output_filename = 'FFN_fic_info.txt'   # Excel output file

    # Primary bookeeping. Read in output file and get list of IDs (so we don't add duplicates)
    IDs = []
    if os.path.isfile(output_filename):    
        with open(output_filename,'r',encoding='utf-8') as output_file:
            reader = csv.reader(output_file,delimiter='\t')
            next(reader, None)  # skip the headers
            for row in reader:
                IDs.append(row[0])

    # If file doesn't exist, make it and add headers
    else:
        with open(output_filename,'w',newline='',encoding='utf-8') as output_file:
            #Add utf-8 BOM
            output_file.write('\ufeff') 
            writer = csv.writer(output_file, delimiter='\t')              
            writer.writerow(['ID','Title','Author','Summary','Rating','Language','Genre',
                'Chapters','Words','Reviews','Favorites','Follows','Characters',
                'Complete','Updated (UTC)','Published (UTC)','URL'])

    # Now open file for appending
    with open(output_filename,'a',newline='',encoding='utf-8') as output_file:

        #Define writer
        writer = csv.writer(output_file, delimiter='\t')          

        # Iterate through the pages define at the top
        print('Beginning web scraping')
        for iPage in range(first_page,first_page + pages_to_parse):	

            # Pick a page
            num_fail = 0
            page_str = base_url + '&p=' + str(iPage)
            while num_fail < allowed_fails:
                time.sleep(pause_length) # Seconds to wait between page requests
                try:
                    page = requests.get(page_str)
                    break
                except:
                    print('Attempt',num_fail,'failed to parse:',page_str)
                    num_fail += 1

            # Quit altogether if we get multiple fails
            if group_fail >= allowed_fails:
                print('Total fail limit exceeded')
                break

            # Try a different page if this one failed
            if num_fail == allowed_fails:
                print('Individual fail limit exceeded')
                group_fail += 1
                continue

            # Now try parsing rest data
            #try:

            # Convert to tree
            tree = html.fromstring(page.text)
            html_tables = tree.xpath('//div[@class="z-list zhover zpointer "]')  
            
            # Parse each fic info
            for table in html_tables:           

                # First get id from link url            
                link_str = table.xpath('./a[@class="stitle"]/@href')[0]
                elements = link_str.split('/')           
                if elements[1]=='s':
                    id = int(elements[2])
                    url = 'https//www.fanfiction.net' + '/'.join(elements[:2])
                else:
                    id = -1
                    url = ''
               

                # Skip over ID if its already in the file
                if str(id) in IDs:
                    print('Skipping',id,': already in file')                        
                    continue

                # Get title and author from /a text
                header = table.xpath('./a/text()')            
                title = header[0]
                author = header[1]               
                
                # Summary from child div                       
                div_text = table.xpath('./div/text()')  
                if div_text:
                    summary = div_text[0]
                else:
                    summary = ''             
                
                # Multiple properties from /div/div
                body = ''.join(table.xpath('./div/div/text()'))
                properties = parseInfo(body)
                
                # Publish and possible update times
                times =  table.xpath('.//span/@data-xutime')
                if len(times)==1:
                    times_utc = [' ', int(times[0])]
                else:
                    times_utc = [int(times[0]), int(times[1])]                    

                # Join everything together in a list
                # ID,title,author,summary,rating,language,genre,chapters,words,reviews,favs,follows,characters,complete,dates,url
                fic_info = [id,title,author,summary] + properties + times_utc + [url]
                writer.writerow(fic_info)
            # except:
            #     print('Could not parse page:',iPage)                  

            # Print progress
            print('Finished page:',iPage)


# This function takes the long string with the fic properties (rating, number of reviews, characters, etc.)
# and parses it to a list with just the properties I want
def parseInfo(info):
    
    # Whether story is completed
    complete = 'Complete' in info
    
    # Properties with names in string. I prefer this to splitting as
    # it makes fewer assumptions about the order/number of properties
    # in the string    
    prop_names= ['Rated','Chapters','Words','Reviews','Favs','Follows']
    prop_values = []
    for name in prop_names:
        # Look for property
        start = info.find(name)
        if start == -1:
            prop_value = 0
        else:
            stop = info.find(' - ',start)
            prop_str = info[start+len(name)+2:stop]
            if name == 'Rated':
                prop_value = prop_str
            else:
                prop_value = int(prop_str.replace(',',''))
        prop_values.append(prop_value)          
        
    # Now get language, genre, and character/pairings
    # This part makes the most assumptions so it is probably buggy
    prop_list = info.split(' - ')
    language = prop_list[1]
    if 'Chapters' in prop_list[2]:
        genre = ' '
    else:
        genre = prop_list[2]
    if complete:
        characters = prop_list[-2]
    else:
        characters = prop_list[-1]

    return [prop_values[0],language,genre] + prop_values[1:] + [characters,complete]

# Standard boilerplate that calls the main() function.
if __name__ == '__main__':
    main()
