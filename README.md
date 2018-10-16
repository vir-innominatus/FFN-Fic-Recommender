# FFN-Fic-Recommender

This is the code and data used to generate the Fic Recommender excel file that makes recommendations for Harry Potter Fanfics

## Output

The final output is [Fic_recommender.xlsx](Fic_recommender.xlsx). The first sheet has the Excel formulas that lookup info from the other sheets. To use the excel file, just enter a Fanfiction.Net ID number (e.g. 4152700) into the cell at the top. The info in the cells below should update automatically.

The code in this repository did not make the Excel formulas in the 1st sheet. It creates the data for the other sheets.

## Required

Matlab
Python 3

## Fanfiction.Net info Webscraper

The script [scrape_ffn_info.py](scrape_ffn_info.py) will scrape Fanfinction.net for the descriptive information for all Harry Potter fanfics (e.g. title, summary, genre). The rate of page requests is limited to comply with Fanficiton.net's TOS. The last scrape I did was on March 31, 2017. The output is >100 MB so it is not in this reporistory. The output then converted to two Matlab .MAT files with [convert_FFN_fic_info_xlsx_to_mat.m](convert_FFN_fic_info_xlsx_to_mat.m)

## Fanfiction.Net User favorites Webscraper

The script [get_author_favs.py](get_author_favs.py) will scrape Fanfinction.net for the list of Favorite stories given a list of Users. I used author usernames from the above excel file. Again, the rate of page requests is limited to comply with Fanficiton.net's TOS. I did not include the raw data in this repository, but I included the already converted MAT file [FFN_author_favs.mat](FFN_author_favs.mat).

From this data, I created the set of feature vectors used for calculating User weights with [make_feature_vector_files.m](make_feature_vector_files.m). These are already generated for the top 30,000 fics with the most favorites in the "Feature vector files" folder. There are 15 files, each with 2000 rows. Each file has 66,602 columns, which represent the favorites of the FFN users that have written 3 or more stories.

## Calculating fic similatiry

The brunt of the calculation is done in [get_weights.m](get_weights.m). It finds the most similar fics for each fic in the feature vector files. It uses the algorithm described in [this blog post](http://colah.github.io/posts/2014-07-FFN-Graphs-Vis/). I chose to calculate the 20 nearest neighbors for each of the 30,000 fics. The output are two arrays that are loaded into an Excel file with [make_excel_sheets.m](make_excel_sheets.m) 

## License

This project is licensed under the Unlicense - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* [This blog post](http://colah.github.io/posts/2014-07-FFN-Graphs-Vis/) post was the primary inspiration for this work