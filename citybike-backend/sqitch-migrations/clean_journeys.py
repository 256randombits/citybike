import pandas as pd
# import numpy as np
import requests
import argparse
import sys


# Use the difference between 'departure_time' and 'return_time'.
# Ignore "Duration (sec.)" as it is redundant and inconsistent
# with the difference between "departure_time" and "return_time".
def remove_journeys_less_than_10_seconds(df):
    df = df[(pd.to_datetime(df['return_time']) -
             pd.to_datetime(df['departure_time'])).dt.total_seconds() >= 10]
    return df


def remove_journeys_with_non_int_distance(df):
    col = 'distance_in_meters'
    df[col] = pd.to_numeric(df[col], errors='coerce')
    df.dropna(inplace=True)
    df[col] = df[col].astype(int)

    return df


def remove_journeys_shorter_than_10_meters(df):
    df = df[df['distance_in_meters'].ge(10)]
    print(df, file=sys.stderr)
    return df


def remove_journeys_with_invalid_stations(df, api):
    url = api + "/stations?select=id"
    # Get ids of stations that can be used.
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        ids = map(lambda x: x.get('id'), data)

        ids_set = set()

        for id in ids:
            ids_set.add(id)
    else:
        print('Failed GET request to: ', url,
              '\nStatus code: ', response.status_code)
        sys.exit(1)
    # Remove the journeys that can not be inserted due to
    # missing data about the stations.
    df = df[df['departure_station_id'].isin(ids_set)]
    df = df[df['return_station_id'].isin(ids_set)]
    return df


def main():
    def parse_arguments():
        parser = argparse.ArgumentParser(
            prog='CleanJourneys',
            description='''Given a csv of journeys
                cleans it and prints it to stdout'''
        )
        parser.add_argument('filename')
        parser.add_argument('--api', required=True,
                            help='''api url without trailing slash
                            Example: http://localhost:3001''')
        return parser.parse_args()

    args = parse_arguments()
    api = args.api
    csvFile = args.filename

    # https://pandas.pydata.org/docs/reference/frame.html
    df = pd.read_csv(csvFile, quotechar='"', usecols=[
                     'Departure', 'Return', 'Departure station id',
                     'Return station id', 'Covered distance (m)'])
    df.columns = [
        "departure_time", "return_time", "departure_station_id",
        "return_station_id", "distance_in_meters"
    ]
    df = remove_journeys_with_non_int_distance(df)

    df = remove_journeys_less_than_10_seconds(df)

    df = remove_journeys_with_invalid_stations(df, api)

    df = remove_journeys_shorter_than_10_meters(df)
    # print(df.to_csv(index=False, float_format='{:,.0f}'.format))
    print(df.to_csv(index=False))
    # print(df.to_csv())


if __name__ == "__main__":
    main()
    exit(0)
