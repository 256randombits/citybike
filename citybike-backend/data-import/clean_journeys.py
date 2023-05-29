import pandas as pd
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


def remove_all_but_integers(df, col):
    df[col] = pd.to_numeric(df[col], errors='coerce')
    df.dropna(inplace=True)
    df[col] = df[col].astype(int)

    return df


def remove_journeys_shorter_than_10_meters(df):
    df = df[df['distance_in_meters'].ge(10)]
    return df


def replace_with_correct_id(df, api):
    url = api + "/stations?select=id,id_in_avoindata"
    # Get ids of stations that can be used.
    response = requests.get(url)
    ids_dict = {}

    if response.status_code == 200:
        data = response.json()

        for row in data:
            ids_dict[row.get('id_in_avoindata')] = row.get('id')

    else:
        print('Failed GET request to: ', url,
              '\nStatus code: ', response.status_code)
        sys.exit(1)
    # Remove the journeys that can not be inserted due to
    # missing data about the stations.
    df = df[df['departure_station_id'].isin(set(ids_dict.keys()))]
    df = df[df['return_station_id'].isin(set(ids_dict.keys()))]

    # Translate the ids
    df = df.replace({'departure_station_id': ids_dict})
    df = df.replace({'return_station_id': ids_dict})
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
    df = (df
          .pipe(remove_all_but_integers, col='distance_in_meters')
          .pipe(remove_all_but_integers, col='departure_station_id')
          .pipe(remove_all_but_integers, col='return_station_id')
          .pipe(remove_journeys_less_than_10_seconds)
          .pipe(replace_with_correct_id, api=api)
          .pipe(remove_journeys_shorter_than_10_meters)
          )

    print(df.to_csv(index=False))


if __name__ == "__main__":
    main()
    exit(0)
