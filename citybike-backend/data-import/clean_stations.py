import pandas as pd
import sys

df = pd.read_csv(sys.argv[1])

# City and the operator are missing from some rows.
# I'm guessing this is because they were implicit
# when there were no stations outside of Helsinki.
df['Kaupunki'] = df['Kaupunki'].replace(to_replace=' ', value='Helsinki')
df['Stad'] = df['Stad'].replace(to_replace=' ', value='Helsingfors')
df['Operaattor'] = df['Operaattor'].replace(
    to_replace=' ', value='CityBike Finland')

print(df.to_csv(index=False))
