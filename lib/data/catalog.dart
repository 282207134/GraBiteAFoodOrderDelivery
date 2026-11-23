class Restaurant {
  const Restaurant(
    this.name,
    this.photo,
    this.categories, {
    this.rating = 4.5,
    this.minutes = 25,
    this.price = 2,
    this.fee = 0,
    this.diet = 'Any',
  });

  final String name;
  final String photo;
  final List<String> categories;
  final double rating;
  final int minutes;
  final int price;
  final int fee;
  final String diet;
}

const daylight = Restaurant(
  'Daylight Coffee',
  'daylight',
  ['Breakfast', 'Bakery'],
  minutes: 20,
  price: 1,
  diet: 'Vegetarian',
);
const mario = Restaurant(
  'Mario Italiano',
  'pasta',
  ['Pizza', 'Dinner'],
  fee: 2,
  diet: 'Vegetarian',
);
const mcdonalds = Restaurant("McDonald's", 'burger', [
  'Burgers',
  'American',
  'Fast Food',
], rating: 4.3);
const halal = Restaurant(
  'The Halal Guys',
  'halal-table',
  ['Chinese', 'Dinner', 'Salads'],
  minutes: 30,
  fee: 3,
);
const cafe = Restaurant(
  "Cafe Brichor’s",
  'cafe',
  ['Bakery', 'Breakfast', 'Burgers', 'Desserts'],
  price: 2,
  diet: 'Vegetarian',
);
const bakery = Restaurant(
  'Mayfield Bakery & Cafe',
  'bakery',
  ['Bakery', 'Breakfast', 'Sandwich', 'Desserts'],
  rating: 4.7,
  price: 3,
);
const tacos = Restaurant('Tacos Nanchas', 'tacos', [
  'Mexican',
  'Dinner',
  'Burgers',
], fee: 1);
const popeyes = Restaurant(
  'Popeyes Elmst',
  'popeyes',
  ['Chinese', 'Fast Food'],
  minutes: 35,
  fee: 4,
);
const mixt = Restaurant(
  'Mixt · Yerba Buena',
  'salad',
  ['Salads', 'Lunch'],
  price: 2,
  diet: 'Vegan',
);
const splitBread = Restaurant('Split Bread · Russian', 'split-bread', [
  'Sandwich',
  'Burgers',
  'Fast Food',
], fee: 2);
const kfc = Restaurant('KFC Foods', 'chicken', [
  'Fast Food',
  'American',
], price: 1);
const richTable = Restaurant(
  'Rich Table',
  'rich-table',
  ['Dinner', 'American'],
  rating: 4.9,
  price: 4,
);
const nethai = Restaurant(
  'Nethai Kitchen',
  'nethai',
  ['Soups', 'Chinese'],
  fee: 3,
  diet: 'Gluten-free',
);
const lazyBear = Restaurant(
  'Lazy Bear',
  'lazy-bear',
  ['Breakfast', 'Dinner'],
  rating: 4.6,
  price: 4,
);
const stateBird = Restaurant(
  'State Bird',
  'state-bird',
  ['Dinner', 'American'],
  price: 3,
  fee: 5,
);
const petitCrenn = Restaurant(
  'Petit Crenn',
  'petit-crenn',
  ['Dinner', 'Salads'],
  price: 4,
  diet: 'Vegan',
);

const restaurants = [
  mcdonalds,
  cafe,
  bakery,
  tacos,
  daylight,
  mario,
  halal,
  popeyes,
  mixt,
  splitBread,
  kfc,
  richTable,
  nethai,
  lazyBear,
  stateBird,
  petitCrenn,
];

const featured = [bakery, cafe, mcdonalds, tacos, mario, kfc];
const topRestaurants = [halal, popeyes, mixt, splitBread, daylight, mario];
const nearby = [nethai, lazyBear, stateBird, petitCrenn, richTable, tacos];

const categories = [
  (label: 'Fast Food', photo: 'category-fast'),
  (label: 'Breakfast & Brunch', photo: 'category-brunch'),
  (label: 'Mexican', photo: 'category-mexican'),
  (label: 'Bakery', photo: 'category-bakery'),
  (label: 'Desserts', photo: 'category-dessert'),
  (label: 'Burgers', photo: 'category-burger'),
];

const cities = [
  'San Francisco',
  'Los Angeles',
  'Chicago',
  'New York City',
  'Texas',
];
const searchExamples = [
  'Subway',
  'Burgers',
  'Sandwich',
  'Pizza',
  'Fried Rice with meat',
  'Bakery',
  'Cake',
];
const foodTypes = [
  'All',
  'Brunch',
  'Dinner',
  'Burgers',
  'Chinese',
  'Pizza',
  'Salads',
  'Soups',
  'Breakfast',
];
const diets = ['Any', 'Vegetarian', 'Vegan', 'Gluten-free'];
const sorts = ['Recommended', 'Fastest Delivery', 'Most Popular'];

class Dish {
  const Dish(this.name, this.photo, this.cents, this.description);

  final String name;
  final String photo;
  final int cents;
  final String description;
}

const cookie = Dish(
  'Cookie Sandwich',
  'cookie',
  740,
  'Shortbread, chocolate turtle cookies, and red velvet.',
);
const combo = Dish(
  'Combo Burger',
  'burger-fries',
  1200,
  'Grilled burger, golden fries, and our house sauce.',
);
const chow = Dish(
  'Chow Fun',
  'chow',
  950,
  'Stir-fried rice noodles with seasonal vegetables.',
);
const dimSum = Dish(
  'Dim Sum',
  'dim-sum',
  1050,
  'Steamed dumplings with a fragrant dipping sauce.',
);
const oyster = Dish(
  'Oyster Dish',
  'rich-table',
  1200,
  'Fresh oysters with a citrus dressing and herbs.',
);
const oysterIce = Dish(
  'Oyster On Ice',
  'halal-table',
  1180,
  'Chilled oysters served over ice with lemon.',
);
const friedRice = Dish(
  'Fried Rice on Pot',
  'nethai',
  890,
  'Fragrant rice tossed with vegetables and egg.',
);

const cookieOptions = [
  'Chocolate Chip',
  'Cookies and Cream',
  'Funfetti',
  'M and M',
  'Red Velvet',
  'Peanut Butter',
  'Snickerdoodle',
];

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
