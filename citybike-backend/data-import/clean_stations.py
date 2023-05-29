import pandas as pd
import sys

# https://pandas.pydata.org/docs/reference/frame.html
df = pd.read_csv(sys.argv[1], quotechar='"', usecols=[
    "ID", "Nimi", "Namn", "Name", "Osoite",
    "Adress", "Kaupunki", "Stad", "Operaattor", "Kapasiteet",
    "x", "y"])

df.columns = [
    "id_in_avoindata", "name_fi", "name_sv", "name_en", "address_fi",
    "address_sv", "city_fi", "city_sv", "operator", "capacity",
    "longitude", "latitude"
]
# City and the operator are missing from some rows.
# I'm guessing this is because they were implicit
# when there were no stations outside of Helsinki.
df['city_fi'] = df['city_fi'].replace(to_replace=' ', value='Helsinki')
df['city_sv'] = df['city_sv'].replace(to_replace=' ', value='Helsingfors')
df['operator'] = df['operator'].replace(
    to_replace=' ', value='CityBike Finland')

print(df.to_csv(index=False))
