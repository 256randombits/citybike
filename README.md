# Citybike

Pre-assignment for Solita Dev Academy 2023.

## Table of Contents
- [Tech Stack](#tech-stack)
- [Getting it running](#getting-it-running)
    - [Initial Setup](#initial-setup)
    - [Setup Backend](#setting-up-backend)
    - [Setup Frontend](#setting-up-frontend)
- [What works](#what-works)

## Tech Stack

The project is built using the following technologies:

- **Frontend**: [Elm](https://elm-lang.org/)
- **Css**: [Tailwindcss](https://tailwindcss.com/)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Backend**: [PostgREST](https://postgrest.org/en/stable/)
- **Migrations**: [SQITCH](https://sqitch.org/)
- **Nix**: [Nix](https://nixos.org/manual/nix/stable/language/index.html)
- **Data Cleaning**: [pandas](https://pandas.pydata.org/)


I chose this stack mainly because I wanted to try out Elm and PostgREST.

## Getting it running

Currently you need [nix](https://nixos.org/download.html) to use this repo.
I tried to create a Docker container with nix inside, but ran into some weird permission errors.
Maybe I'll manage to fix them soon.

> **Hint:** You can check which targets exists by runing `nix flake show`.
> Most of the targets are just wrapping the usage of some program.

> **NB:** You need multiple shells to run these commands.
### Initial setup
1. Create `.env` file
```bash
cd citybike-backend

cp .env.example .env
```

### Setting up backend
1. Run services
```bash
docker-compose up
```
<details>
    <summary>More details</summary>
    <ol>
    <li>Start PostgreSQL</li>
    <li>Run <a href="citybike-backend/pginit/create-postgrest-auth-user.sh">create-postgrest-auth-user.sh</a>, because it's mounted inside of <b>/docker-entrypoint-initdb.d</b>.</li>
    <li>Start PostgREST server (we'll cover what it does in more details once we've run migrations.)</li>
    <li>Because of docker-compose.override.yml:</li>
        <ol>
        <li>Start SwaggerUI that points to the OpenAPI spec provided by PostgREST.</li>
        <li>Start pgAdmin (login postgresuser postgrespw if using .env from example).</li>
        </ol>
    </ol>
</details>

2. Import data
```bash
# If there was data it would be removed.
nix run .#destroy-and-initialize
```
<details>
    <summary>More details</summary>
    <ol>
    <li>Runs the <b>outputs.destroy-and-initialize.system</b> target inside of flake.nix
        </ul>
        <ul>
        <li>If there were deployed migrations, you would be prompted to revert them.</li>
        <li>It is just a combination of runing bash and python scripts.</li>
        <li>If it fails just run it again. (Has happened once, but I was unable to reproduce it, so might have been unsaved file or smth.)</li>
        </ul>
    </li>
    <li>Deploys migrations to database.
        <ul>
        <li>A test is run after each migration to verify that it succeeds. (These are not perfect)</li>
        </ul>
        <ul>
        <li>Some tests test that the api works as expected. (eg. that the correct rank1 destination of a station is returned.)</li>
        </ul>
    </li>
    <li>PostgREST generates an API based on the tables, views and functions inside the <b>api</b> schema.</li>
    <li>Csv files are downloaded and their hashes are checked against hashes inside of <b>flake.lock</b>
        <ul>
        <li>Just using them triggers this.</li>
        <li>They are cached inside of /nix/store so you have to download them only once.</li>
        </ul>
    </li>
    <li>Stations are cleaned by clean_stations.py and imported via curl</li>
    <li>Journeys are cleaned by clean_journeys.py and imported via curl
         <ul>
         <li>Importing of journeys would fail if it contained anything invalid so stations that exist are fetched.</li>
         </ul>
    </li>
    <li>Data is now imported.</li>
    </ol>
</details>

### Setting up frontend
1. Start elm dev-server
```bash
nix run .#elm-live
```
2. Run tailwindcss
```bash
nix run .#tailwindcss
```
3. elm-live tells which url can be used.

## What works

### Data import

#### Recommended

- [x] Import data from the CSV files to a database or in-memory storage
- [x] Validate data before importing
- [x] Don't import journeys that lasted for less than ten seconds
- [x] Don't import journeys that covered distances shorter than 10 meters

### Journey list view
#### Recommended

- [x] List journeys
- [x] For each journey show departure and return stations, covered distance in kilometers and duration in minutes

#### Additional

- [] Pagination
- [] Ordering per column
- [] Searching
- [] Filtering

### Station list
#### Recommended

- [x] List all the stations

#### Additional

- [?] Searching 
- [?] Pagination
- Did exist in [commit](https://github.com/256randombits/citybike/tree/8ad166ee64d2f5cd86a90673a158314bd1eeef9f) as "Load More" pagination.


### Single station view
#### Recommended

- [x] Station name
- [?] Station address
- [?] Total number of journeys starting from the station
- [?] Total number of journeys ending at the station

#### Additional

Endpoints for getting these exist. (Map does not exist)
- [-] Station location on the map
- [~] The average distance of a journey starting from the station
- [~] The average distance of a journey ending at the station
- [~] Top 5 most popular return stations for journeys starting from the station
- [~] Top 5 most popular departure stations for journeys ending at the station
- [~] Ability to filter all the calculations per month
