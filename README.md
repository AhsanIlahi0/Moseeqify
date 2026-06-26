<p align="center">
  <img src="Frontend/moseeqify/public/logo.png" alt="Moseeqify logo" width="320">
</p>

<h1 align="center">Moseeqify</h1>

<p align="center">
  A full-stack music streaming web app — browse artists, albums and songs, build playlists, and pick up where you left off with listening history.
</p>

---

## Overview

Moseeqify is a Spotify-style music streaming application built as a three-tier project:

- **Frontend** — a React (Vite) single-page app for browsing music, managing playlists, and playing songs.
- **Backend** — a Flask REST API that handles authentication, search, playlists, and listening history.
- **Database** — a Microsoft SQL Server schema with stored procedures and triggers for all CRUD operations and audit logging.

## Features

- 🔐 **User accounts** — register and log in (with a minimum-age check enforced at the database level).
- 🎵 **Browse music** — view all songs, albums, and album detail pages with track listings.
- 📃 **Playlists** — create playlists and add songs to them.
- 🔎 **Live search** — search songs by title as you type.
- 🕘 **Listening history** — every song played is logged and shown back to the user.
- 👤 **Follow artists** — follow/unfollow artists (API supported).
- ▶️ **Persistent audio player** — a global player (built on `react-h5-audio-player`) that keeps playing across page navigation.

## Tech Stack

| Layer    | Technology |
|----------|------------|
| Frontend | React 18, Vite, React Router, Tailwind CSS, Axios, Framer Motion, react-h5-audio-player, react-toastify |
| Backend  | Python, Flask, Flask-SQLAlchemy, Flask-Login, Flask-CORS |
| Database | Microsoft SQL Server (via `pyodbc` / ODBC Driver 17), stored procedures & triggers |

## Project Structure

```
Moseeqify-main/
├── Backend/
│   ├── app.py              # Flask app & REST API routes
│   ├── config.py           # App config (secret key, DB connection string, CORS)
│   ├── models.py           # SQLAlchemy models (User, Artist, Album, Song, Playlist, ...)
│   └── templates/          # Legacy server-rendered HTML templates (unused by the SPA)
├── Database/
│   ├── moseeqify.sql              # Database & table creation
│   ├── insert_procedures.sql      # INSERT stored procedures
│   ├── update_procedures.sql      # UPDATE stored procedures
│   ├── delete_procedures.sql      # DELETE stored procedures
│   ├── triggers.sql               # Audit/logging triggers for every table
│   ├── data.sql / test_Data.sql   # Sample/seed data
│   └── test_Queries.sql
└── Frontend/
    └── moseeqify/
        ├── src/
        │   ├── components/
        │   │   ├── auth/          # Login, Register
        │   │   ├── albums/        # Albums list, single album view
        │   │   ├── playlists/     # Playlists list, single playlist, create/add-song modals
        │   │   ├── songs/         # Songs list page
        │   │   ├── home/          # Home, Welcome, Listening history
        │   │   ├── musicPlayer/   # Global audio player
        │   │   └── navbar/        # Navbar, search
        │   ├── contexts/          # UserContext (auth state), MusicContext (now-playing state)
        │   └── App.jsx            # Route definitions
        └── package.json
```

## Database Schema

Core tables: `User`, `Artist`, `Genre`, `Album`, `Song`, `Playlist`, plus junction/log tables `AlbumSongs`, `PlaylistSongs`, `UserListeningHistory`, and `user_follows_artists`.

Key relationships:

- An **Artist** has many **Albums** and **Songs**.
- An **Album** has many **Songs** (via `AlbumSongs`).
- A **Playlist** belongs to a **User** and contains many **Songs** (via `PlaylistSongs`).
- **UserListeningHistory** logs every song a user plays.
- **user_follows_artists** tracks which artists a user follows.

Every table also has matching `INSERT`/`UPDATE`/`DELETE` stored procedures and `AFTER INSERT/UPDATE/DELETE` triggers (in `Database/triggers.sql`) that print an audit message whenever a row changes — useful for tracing activity directly from SQL Server Management Studio.

## API Reference

Base URL: `http://localhost:5000`

| Method | Endpoint | Description |
|--------|----------|--------------|
| POST   | `/register` | Create a new user account |
| POST   | `/login` | Log in with email + password |
| GET    | `/logout` | Log out the current user |
| GET    | `/songs` | Get all songs |
| GET    | `/albums` | Get all albums |
| GET    | `/albums/<album_id>/` | Get a single album with its tracklist |
| POST   | `/search` | Search songs by title (`{ "query": "..." }`) |
| GET    | `/playlists` | Get all playlists |
| POST   | `/playlists` | Create a playlist (`{ "name": "...", "username": "..." }`) |
| GET    | `/playlists/<playlist_id>` | Get a single playlist with its songs |
| POST   | `/playlists/<playlist_id>/add-song/<song_id>` | Add a song to a playlist |
| POST   | `/save-to-history/<song_id>` | Log a played song to the user's listening history |
| GET    | `/users/<username>/listening-history` | Get a user's listening history |
| POST   | `/follow-artist/<artist_id>` | Follow an artist (auth required) |
| POST   | `/unfollow-artist/<artist_id>` | Unfollow an artist (auth required) |

## Getting Started

### Prerequisites

- Python 3.9+
- Node.js 16+ and npm
- Microsoft SQL Server + the [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server)

### 1. Set up the database

1. Open SQL Server Management Studio (or `sqlcmd`) and run, in order:
   - `Database/moseeqify.sql` — creates the database and tables
   - `Database/insert_procedures.sql`, `update_procedures.sql`, `delete_procedures.sql` — stored procedures
   - `Database/triggers.sql` — audit triggers
   - `Database/data.sql` (and/or `test_Data.sql`) — sample data

### 2. Run the backend

```bash
cd Backend
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install flask flask-sqlalchemy flask-cors flask-login pyodbc
```

Update the `SQLALCHEMY_DATABASE_URI` in `config.py` (or set a `DATABASE_URL` environment variable) to point at your SQL Server instance, e.g.:

```
mssql+pyodbc://<SERVER>/moseeqify?driver=ODBC+Driver+17+for+SQL+Server
```

Then start the API:

```bash
python app.py
```

The API runs on `http://localhost:5000`.

### 3. Run the frontend

```bash
cd Frontend/moseeqify
npm install
npm run dev
```

The app runs on `http://localhost:5173` and is pre-configured (via CORS in the backend) to talk to the API on port 5000.

## Notes

- `SECRET_KEY` and the database connection string should be moved to environment variables for any real deployment — they're currently hard-coded defaults in `config.py`.
- Passwords are currently stored and compared in plain text; this should be replaced with proper hashing (e.g. `werkzeug.security` or `bcrypt`) before any production use.
- `Backend/templates/` contains an earlier server-rendered (Jinja) version of the UI that is no longer wired up to `app.py`; the React app in `Frontend/` is the active frontend.

## License

No license file is currently included in this repository. Add one (e.g. MIT) if you intend to share or open-source this project.
