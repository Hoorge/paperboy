# python.exe -m pip install google-api-python-client
#!/usr/bin/python

# This sample executes a search request for the specified search term.
# Sample usage:
#   python search.py --q=surfing --max-results=10
# NOTE: To use the sample, you must provide a developer key obtained
#       in the Google APIs Console. Search for "REPLACE_ME" in this code
#       to find the correct place to provide that key..

import argparse, sys, json, datetime
from datetime import timedelta

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Set DEVELOPER_KEY to the API key value from the APIs & auth > Registered apps
# tab of
#   https://cloud.google.com/console
# Please ensure that you have enabled the YouTube Data API for your project.

def youtube_search(options):
    # DEVELOPER_KEY = 'AIzaSyA30l8KSuXItQGDWVeBAAauZpXPaHhgfco'
    # YOUTUBE_API_SERVICE_NAME = 'youtube'
    # YOUTUBE_API_VERSION = 'v3'
    youtube = build(
        options.youtube_api_service_name,
        options.youtube_api_version,
        developerKey=options.developer_key)

    # Call the search.list method to retrieve results matching the specified
    # query term.
    search_response = youtube.search().list(
        q=options.q,
        part='id,snippet',
        maxResults=options.max_results,
        order=options.order,
        type=options.type
        # metrics=options.metrics
    ).execute()


    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    #for key, value in search_response.items():
    #    print(key, value, '\n')

    #for search_result in search_response.get('item', []):
    for search_result in search_response.get('items', []):
        #for key, value in search_result.items():
        #    print(key, value, '\n')
        result = {}
        result['kind'] = search_result['id']['kind'].replace("youtube#","")
        result['id'] = search_result['id']
        result['video_url'] = 'https://www.youtube.com/watch?v={}'.format(search_result['id']['videoId'])
        result['date'] = search_result['snippet']['publishedAt']
        result['title'] = search_result['snippet']['title']
        result['description'] = search_result['snippet']['description']
        result['channelTitle'] = search_result['snippet']['channelTitle']

        # print(search_result)
        print(json.dumps(result))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # Search
    parser.add_argument('--q', help='Search term', default='powershell')
    parser.add_argument('--max-results', help='Max results', default=50)
    parser.add_argument('--order', help='Sort order', default='date')
    parser.add_argument('--type', help='type of content', default='video')
    parser.add_argument('--developer-key', help='Youtube Developer Key')
    parser.add_argument('--youtube-api-service-name', help='Youtube API Service Name')
    parser.add_argument('--youtube-api-version', help='Youtube API version', default='v3')
    parser.add_argument('--metrics', help='Report metrics', default='views,comments,favoritesAdded,favoritesRemoved,likes,dislikes,shares')
    args = parser.parse_args()

    try:
        youtube_search(args)
    except Exception as e: # If an exception is catched in the try block, the except block is executed
        print('An HTTP error {0} occurred:\n{1}'.format(e.resp.status, e.content) )
