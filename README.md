# SkyWays Airline Management System

## Overview
This is a Flask web application to manage airline operations including flights, aircraft, and crew using a MySQL database.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Configure database credentials in `config.py`.

3. Run the app:
```bash
python app.py
```

## Endpoints

- `/` – Main dashboard
- `/api/flights` – GET all flights or POST new flight

## Notes

Ensure the MySQL database `skyways_airline_management` is set up using the provided SQL schema.
