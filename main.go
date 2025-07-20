package main

import(
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	_ "github.com/mattn/go-sqlite3"

)

// Event structure
type Event struct{
	ID			int			`json:"id"`
	Title		string		`json:"title"`
	Description	string		`json:"description"`
	Date 		time.Time	`json:"date"`
	Location	string		`json:"location"`
	Latitude 	float64		`json:"latitude"`
	Longitude	float64		`json:"longitude"`
}

// User Location
type UserLocation struct{
	UserId 		int 		`json:"user_id"`
	Latitude	float64		`json:"latitude"`
	Longitude	float64		`json:"longitude"`
}

var db *sql.DB
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {return true},
}
var clients = make(map[*websocket.Conn]bool)
var mutex =  &sync.Mutex{}

func initDB() {
	var err error
	db, err = sql.Open("sqlite3", "./events.db")
	if err != nil{
		panic(err)
	}

	// Create events table if not exists
	createEventsTable := `
	CREATE TABLE IF NOT EXISTS events (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		title TEXT NOT NULL,
		description TEXT NOT NULL, 
		date TEXT NOT NULL, 
		location TEXT NOT NULL,
		latitude REAL NOT NULL,
		longitude REAL NOT NULL
	);`
	_, err = db.Exec(createEventsTable)
	if err != nil{
		panic(err)
	}

	// Create user table if not exists
	createUsersTable := `
	CREATE TABLE IF NOT EXISTS users (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		latitude REAL NOT NULL,
		longitude REAL NOT NULL
	);`
	_, err = db.Exec(createUsersTable)
	if err != nil{
		panic(err)
	}
}

func getEvents() []Event{
	rows, err := db.Query("SELECT id, title, description, date, location, latitude, longitude FROM events")
    if err != nil {
        panic(err)
    }
    defer rows.Close()

	var events []Event
    for rows.Next() {
        var e Event
        var dateString string
        err := rows.Scan(&e.ID, &e.Title, &e.Description, &dateString, &e.Location, &e.Latitude, &e.Longitude)
        if err != nil {
            panic(err)
        }
        // Parse the date string into a time.Time object
        e.Date, err = time.Parse("2006-01-02", dateString)
        if err != nil {
            log.Printf("Error parsing date: %v", err)
        }
        events = append(events, e)
    }
    return events
}

func addEvent(title, description string, date time.Time, location string, latitude, longitude float64) {
    stmt, err := db.Prepare("INSERT INTO events (title, description, date, location, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)")
    if err != nil {
        panic(err)
    }
    defer stmt.Close()

    // Format the date as ISO 8601 before storing it in the database
    _, err = stmt.Exec(title, description, date.Format("2006-01-02"), location, latitude, longitude)
    if err != nil {
        panic(err)
    }
}

func saveUserLocation(lat, lng float64) {
    stmt, err := db.Prepare("INSERT INTO users (latitude, longitude) VALUES (?, ?)")
    if err != nil {
        panic(err)
    }
    defer stmt.Close()

    _, err = stmt.Exec(lat, lng)
    if err != nil {
        panic(err)
    }
}

func main(){
	initDB()
	defer db.Close()

	// Serve static
	fs:= http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	//Home page route
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request){
		events := getEvents()
		tmpl := template.Must(template.ParseFiles("templates/index.html"))
		tmpl.Execute(w, events)
	})

	//Add event route
	http.HandleFunc("/add-event", func(w http.ResponseWriter, r *http.Request){
		if r.Method == http.MethodPost{
			r.ParseForm()
			dateString := r.FormValue("date")
			date, err := time.Parse("2006-01-02", dateString)
            if err != nil {
                http.Error(w, "Invalid date format", http.StatusBadRequest)
                return
            }
            addEvent(
				r.FormValue("title"),
				r.FormValue("description"),
                date,
                r.FormValue("location"),
                parseCoordinate(r.FormValue("latitude")),
                parseCoordinate(r.FormValue("longitude")),
            )
			events := getEvents()
			tmpl:=template.Must(template.ParseFiles("templates/event-list.html"))
            tmpl.Execute(w, events)
            return
		}
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
	})
	// Delete Event
	http.HandleFunc("/delete-event", func(w http.ResponseWriter, r *http.Request) {
    if r.Method == http.MethodPost {
        r.ParseForm()
        id := r.FormValue("id")
        stmt, err := db.Prepare("DELETE FROM events WHERE id = ?")
        if err != nil {
            http.Error(w, "Internal Server Error", http.StatusInternalServerError)
            return
        }
        defer stmt.Close()

        _, err = stmt.Exec(id)
        if err != nil {
            http.Error(w, "Internal Server Error", http.StatusInternalServerError)
            return
        }

        events := getEvents()
        tmpl := template.Must(template.ParseFiles("templates/event-list.html"))
        tmpl.Execute(w, events)
    }
	})

	//Fetch Events as JSON -> map related
	http.HandleFunc("/api/events", func(w http.ResponseWriter, r *http.Request) {
    events := getEvents()
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(events)
	})

	fmt.Println("Server running on http://localhost:8080")
    http.ListenAndServe(":8080", nil)
}

func parseCoordinate(value string) float64 {
    var f float64
    fmt.Sscanf(value, "%f", &f)
    return f
}
