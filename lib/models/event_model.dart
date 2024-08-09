// TODO: modify hardly
import 'package:ndovaj/persistence/eventrepo.dart';

class Event {
  String name;
  String description;
  DateTime eventDate;
  String image;
  String location;
  String organizer;
  String price;

  Event({
    required this.eventDate,
    required this.image,
    required this.location,
    required this.name,
    required this.organizer,
    required this.price,
    required this.description,
  });
}
EventRepo repo = EventRepo();
final List<Event> upcomingEvents = repo.getEvents();
final List<Event> nearbyEvents = repo.nearbyEvents;

/*
final List<Event> upcomingEvents = [
  Event(
    name: "Bonefro Rock",
    eventDate: DateTime.now().add(const Duration(days: 0)),
    image: 'https://source.unsplash.com/800x600/?concert',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "Bonefro",
    organizer: "Westfield Centre",
    price: "free",
  ),
  Event(
    name: "Live Orchestra",
    eventDate: DateTime.now().add(const Duration(days: 33)),
    image: 'https://source.unsplash.com/800x600/?band',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "David Geffen Hall",
    organizer: "Westfield Centre",
    price: "30",
  ),
  Event(
    name: "Local Concert",
    eventDate: DateTime.now().add(const Duration(days: 12)),
    image: 'https://source.unsplash.com/800x600/?music',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "The Cutting room",
    organizer: "Westfield Centre",
    price: "30",
  ),
];

final List<Event> nearbyEvents = [
  Event(
    name: "The Pretty Reckless",
    eventDate: DateTime.now().add(const Duration(days: 1)),
    image: 'https://source.unsplash.com/600x800/?concert',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "Fairview Gospel Church",
    organizer: "Westfield Centre",
    price: "30",
  ),
  Event(
    name: "New Thread Quartet",
    eventDate: DateTime.now().add(const Duration(days: 4)),
    image: 'https://source.unsplash.com/600x800/?live',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "David Geffen Hall",
    organizer: "Westfield Centre",
    price: "30",
  ),
  Event(
    name: "Songwriters in Concert",
    eventDate: DateTime.now().add(const Duration(days: 2)),
    image: 'https://source.unsplash.com/600x800/?orchestra',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "The Cutting room",
    organizer: "Westfield Centre",
    price: "30",
  ),
  Event(
    name: "Rock Concert",
    eventDate: DateTime.now().add(const Duration(days: 21)),
    image: 'https://source.unsplash.com/600x800/?music',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "The Cutting room",
    organizer: "Westfield Centre",
    price: "32",
  ),
  Event(
    name: "Songwriters in Concert",
    eventDate: DateTime.now().add(const Duration(days: 16)),
    image: 'https://source.unsplash.com/600x800/?rock_music',
    description: "The pretty reckless is an American rock band from New york city, Formed in 2009. The",
    location: "David Field",
    organizer: "Westfield Centre",
    price: "14",
  ),
];*/