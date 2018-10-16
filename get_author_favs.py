import requests, csv, time
from bs4 import BeautifulSoup
from urllib.parse import urlparse, parse_qs, urlencode
import re, json
from math import ceil

def main():

    ffn_url = 'https://www.fanfiction.net'
    query_dict = {'keywords': '', 'ready':'1', 'type':'writer'}

    # Get list of all authors
    authors = []
    with open('FFN_authors.csv') as csv_file:
        
        #Ignore header
        header_line = next(csv_file) 

        # Read in all authors
        csv_reader = csv.reader(csv_file, delimiter=',')        
        for row in csv_reader:
            authors.append(row[0]) 
    print('There are',len(authors),'authors')
    
    # Figure out how many files to make
    num_authors_per_file = 100
    num_files = ceil(len(authors)/num_authors_per_file)
    for iFile in range(830,num_files):

        fav_data = []
        with open('Author Favs data\FFN_author_favs' + str(iFile)+ '.json','w') as json_file:

            # Search google for author on FFN.net
                        
            for iAuthor in range(num_authors_per_file):
                
                # Try to get page
                author_ind = iAuthor + iFile*num_authors_per_file
                if author_ind == len(authors):
                    break
                author = authors[author_ind]
                query_dict['keywords'] = author 
                try:        
                    page = requests.get(ffn_url + '/search/?' + urlencode(query_dict))
                    time.sleep(0.5)

                    # Parse google result to get list of users returned by search of first link
                    soup = BeautifulSoup(page.content, features='lxml')
                    all_links = soup.find_all('a')

                    if all_links:
                        users = [link['href'] for link in all_links if '/u/' in link['href']]
                    
                        # If multiple users, take first result
                        if users:
                            user_url = ffn_url + users[0]
                            fav_IDs = get_favorite_IDs(user_url)
                            fav_data.append({'author': author, 
                                'url':user_url, 
                                'fav_IDs':fav_IDs})
                            print('Finished author',author)
                            #url_file.write(user_url + '\n')
                except:
                    print('Couldn\'t get search page for',author)

            json.dump(fav_data,json_file)
        
        print('Finished file:',json_file.name,'\n')

def get_favorite_IDs(user_url):
    #This function will take the URL for a FFN user and return the of HP favorites
    IDs = []
    attributes = {'class':'z-list favstories', 'data-category':'Harry Potter'}
    try:

        #Get page with user info        
        page = requests.get(user_url)
        time.sleep(0.5)
        soup = BeautifulSoup(page.content, features='lxml')

        # Iterate through favorites, getting ID
        
        for favorite in soup.find_all('div', attrs=attributes):            
            story_url = favorite.find('a',class_='stitle')['href']
            url_pieces = story_url.split('/')           
            if url_pieces[1]=='s':
                IDs.append(int(url_pieces[2]))
    except:
        print('Could not get favorites for:',user_url)
    
    # Return the filled ID list
    return IDs


# Standard boilerplate that calls the main() function.
if __name__ == '__main__':
    main()

  