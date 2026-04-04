// Common data for data tables
export const items = [
  { name: 'Frozen Yogurt', calories: 159, fat: 6.0, carbs: 24, protein: 4.0, sodium: 87, calcium: '14%', iron: '1%' },
  { name: 'Ice cream sandwich', calories: 237, fat: 9.0, carbs: 37, protein: 4.3, sodium: 129, calcium: '8%', iron: '1%' },
  { name: 'Eclair', calories: 262, fat: 16.0, carbs: 23, protein: 6.0, sodium: 337, calcium: '6%', iron: '7%' },
  { name: 'Cupcake', calories: 305, fat: 3.7, carbs: 67, protein: 4.3, sodium: 413, calcium: '3%', iron: '8%' },
  { name: 'Gingerbread', calories: 356, fat: 16.0, carbs: 49, protein: 3.9, sodium: 327, calcium: '7%', iron: '16%' },
  { name: 'Jelly bean', calories: 375, fat: 0.0, carbs: 94, protein: 0.0, sodium: 50, calcium: '0%', iron: '0%' },
  { name: 'Lollipop', calories: 392, fat: 0.2, carbs: 98, protein: 0, sodium: 38, calcium: '0%', iron: '2%' },
  { name: 'Honeycomb', calories: 408, fat: 3.2, carbs: 87, protein: 6.5, sodium: 562, calcium: '0%', iron: '45%' },
  { name: 'Donut', calories: 452, fat: 25.0, carbs: 51, protein: 4.9, sodium: 326, calcium: '2%', iron: '22%' },
  { name: 'KitKat', calories: 518, fat: 26.0, carbs: 65, protein: 7, sodium: 54, calcium: '12%', iron: '6%' },
  { name: 'Chocolate Cake', calories: 389, fat: 18.0, carbs: 55, protein: 5.2, sodium: 298, calcium: '8%', iron: '12%' },
  { name: 'Apple Pie', calories: 296, fat: 14.0, carbs: 43, protein: 2.4, sodium: 327, calcium: '4%', iron: '3%' },
  { name: 'Cheesecake', calories: 321, fat: 23.0, carbs: 26, protein: 5.5, sodium: 374, calcium: '15%', iron: '2%' },
  { name: 'Brownie', calories: 466, fat: 20.0, carbs: 71, protein: 6.8, sodium: 175, calcium: '6%', iron: '18%' },
  { name: 'Muffin', calories: 377, fat: 17.0, carbs: 54, protein: 6.2, sodium: 422, calcium: '9%', iron: '8%' },
  { name: 'Pancakes', calories: 227, fat: 9.0, carbs: 28, protein: 6.0, sodium: 439, calcium: '18%', iron: '7%' },
  { name: 'Waffles', calories: 291, fat: 15.0, carbs: 33, protein: 8.2, sodium: 383, calcium: '12%', iron: '9%' },
  { name: 'Cookies', calories: 502, fat: 25.0, carbs: 67, protein: 5.6, sodium: 386, calcium: '3%', iron: '15%' },
  { name: 'Pudding', calories: 158, fat: 4.0, carbs: 28, protein: 4.4, sodium: 155, calcium: '13%', iron: '1%' },
  { name: 'Tiramisu', calories: 240, fat: 13.0, carbs: 28, protein: 4.6, sodium: 76, calcium: '11%', iron: '4%' },
  { name: 'Gelato', calories: 196, fat: 8.0, carbs: 29, protein: 4.1, sodium: 63, calcium: '12%', iron: '1%' },
  { name: 'Sorbet', calories: 134, fat: 0.3, carbs: 34, protein: 0.9, sodium: 7, calcium: '1%', iron: '2%' },
  { name: 'Macarons', calories: 95, fat: 4.5, carbs: 13, protein: 1.7, sodium: 12, calcium: '2%', iron: '1%' },
  { name: 'Cannoli', calories: 231, fat: 12.0, carbs: 27, protein: 6.0, sodium: 91, calcium: '8%', iron: '5%' },
  { name: 'Baklava', calories: 334, fat: 23.0, carbs: 29, protein: 4.1, sodium: 242, calcium: '6%', iron: '7%' },
  { name: 'Flan', calories: 223, fat: 6.8, carbs: 35, protein: 6.1, sodium: 101, calcium: '15%', iron: '3%' },
  { name: 'Tart', calories: 276, fat: 16.0, carbs: 31, protein: 3.2, sodium: 198, calcium: '4%', iron: '6%' },
  { name: 'Profiteroles', calories: 178, fat: 11.0, carbs: 17, protein: 4.2, sodium: 89, calcium: '7%', iron: '4%' },
  { name: 'Mousse', calories: 189, fat: 14.0, carbs: 13, protein: 3.8, sodium: 45, calcium: '5%', iron: '8%' },
  { name: 'Soufflé', calories: 156, fat: 8.0, carbs: 18, protein: 5.1, sodium: 167, calcium: '9%', iron: '3%' }
];

export const headers = [
  { title: 'Pyramid', key: 'name' },
  { title: 'Location', key: 'location' },
  { title: 'Construction Date', key: 'constructionDate' },
  {
    title: 'Dimensions',
    align: 'center' as const,
    children: [
      { title: 'Height(m)', key: 'height' },
      { title: 'Base(m)', key: 'base' },
      { title: 'Volume(m³)', key: 'volume' }
    ]
  }
];

export const headertable = [
  {
    name: 'Great Pyramid of Giza',
    location: 'Egypt',
    height: '146.6',
    base: '230.4',
    volume: '2583285',
    constructionDate: 'c. 2580–2560 BC'
  },
  {
    name: 'Pyramid of Khafre',
    location: 'Egypt',
    height: '136.4',
    base: '215.3',
    volume: '1477485',
    constructionDate: 'c. 2570 BC'
  },
  {
    name: 'Red Pyramid',
    location: 'Egypt',
    height: '104',
    base: '220',
    volume: '1602895',
    constructionDate: 'c. 2590 BC'
  },
  {
    name: 'Bent Pyramid',
    location: 'Egypt',
    height: '101.1',
    base: '188.6',
    volume: '1200690',
    constructionDate: 'c. 2600 BC'
  },
  {
    name: 'Pyramid of the Sun',
    location: 'Mexico',
    height: '65',
    base: '225',
    volume: '1237097',
    constructionDate: 'c. 200 CE'
  }
];

export const densityHeaders = [
  { title: 'Plant', align: 'start' as const, sortable: false, key: 'name' },
  { title: 'Light', align: 'end' as const, key: 'light' },
  { title: 'Height', align: 'end' as const, key: 'height' },
  { title: 'Pet Friendly', align: 'end' as const, key: 'petFriendly' },
  { title: 'Price ($)', align: 'end' as const, key: 'price' }
];

export const plants = [
  {
    name: 'Fern',
    light: 'Low',
    height: '20cm',
    petFriendly: 'Yes',
    price: 20
  },
  {
    name: 'Snake Plant',
    light: 'Low',
    height: '50cm',
    petFriendly: 'No',
    price: 35
  },
  {
    name: 'Monstera',
    light: 'Medium',
    height: '60cm',
    petFriendly: 'No',
    price: 50
  },
  {
    name: 'Pothos',
    light: 'Low to medium',
    height: '40cm',
    petFriendly: 'Yes',
    price: 25
  },
  {
    name: 'ZZ Plant',
    light: 'Low to medium',
    height: '90cm',
    petFriendly: 'Yes',
    price: 30
  },
  {
    name: 'Spider Plant',
    light: 'Bright, indirect',
    height: '30cm',
    petFriendly: 'Yes',
    price: 15
  },
  {
    name: 'Air Plant',
    light: 'Bright, indirect',
    height: '15cm',
    petFriendly: 'Yes',
    price: 10
  },
  {
    name: 'Peperomia',
    light: 'Bright, indirect',
    height: '25cm',
    petFriendly: 'Yes',
    price: 20
  },
  {
    name: 'Aloe Vera',
    light: 'Bright, direct',
    height: '30cm',
    petFriendly: 'Yes',
    price: 15
  },
  {
    name: 'Jade Plant',
    light: 'Bright, direct',
    height: '40cm',
    petFriendly: 'Yes',
    price: 25
  }
];

export const hideTable = [
  {
    title: 'Dessert(100g serving)',
    align: 'start' as const,
    key: 'name'
  },
  { title: 'Calories', align: 'end' as const, key: 'calories' },
  { title: 'Fat(g)', align: 'end' as const, key: 'fat' },
  { title: 'Carbs(g)', align: 'end' as const, key: 'carbs' },
  { title: 'Protein(g)', align: 'end' as const, key: 'protein' },
  { title: 'Iron(%)', align: 'end' as const, key: 'iron' }
];

export const desserts = [
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: '1%'
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: '1%'
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: '7%'
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: '8%'
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: '16%'
  },
  {
    name: 'Jelly bean',
    calories: 375,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: '0%'
  },
  {
    name: 'Lollipop',
    calories: 392,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: '2%'
  }
];

export const selectionItems = [
  {
    name: '🍎 Apple',
    location: 'Washington',
    height: '0.1',
    base: '0.07',
    volume: '0.0001'
  },
  {
    name: '🍌 Banana',
    location: 'Ecuador',
    height: '0.2',
    base: '0.05',
    volume: '0.0002'
  },
  {
    name: '🍇 Grapes',
    location: 'Italy',
    height: '0.02',
    base: '0.02',
    volume: '0.00001'
  },
  {
    name: '🍉 Watermelon',
    location: 'China',
    height: '0.4',
    base: '0.3',
    volume: '0.03'
  },
  {
    name: '🍍 Pineapple',
    location: 'Thailand',
    height: '0.3',
    base: '0.2',
    volume: '0.005'
  },
  {
    name: '🍒 Cherries',
    location: 'Turkey',
    height: '0.02',
    base: '0.02',
    volume: '0.00001'
  },
  {
    name: '🥭 Mango',
    location: 'India',
    height: '0.15',
    base: '0.1',
    volume: '0.0005'
  },
  {
    name: '🍓 Strawberry',
    location: 'USA',
    height: '0.03',
    base: '0.03',
    volume: '0.00002'
  },
  {
    name: '🍑 Peach',
    location: 'China',
    height: '0.09',
    base: '0.08',
    volume: '0.0004'
  },
  {
    name: '🥝 Kiwi',
    location: 'New Zealand',
    height: '0.05',
    base: '0.05',
    volume: '0.0001'
  }
];

export const groupBy = [{ key: 'category', order: 'asc' }];

export const groupheaders = [
  { key: 'data-table-group', title: 'Category' },
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    key: 'name',
    groupable: false
  },
  { title: 'Dairy', key: 'dairy', align: 'end' as const }
];

export const groupdesserts = [
  {
    name: 'Frozen Yogurt',
    category: 'Ice cream',
    status: 'Available',
    dairy: 'Yes'
  },
  {
    name: 'Ice cream sandwich',
    category: 'Ice cream',
    status: 'Available',
    dairy: 'Yes'
  },
  {
    name: 'Eclair',
    category: 'Cookie',
    status: 'Out of stock',
    dairy: 'Yes'
  },
  {
    name: 'Cupcake',
    category: 'Pastry',
    status: 'Out of stock',
    dairy: 'Yes'
  },
  {
    name: 'Gingerbread',
    category: 'Cookie',
    status: 'Available',
    dairy: 'No'
  },
  {
    name: 'Jelly bean',
    category: 'Candy',
    status: 'Available',
    dairy: 'No'
  },
  {
    name: 'Lollipop',
    category: 'Candy',
    status: 'Out of stock',
    dairy: 'No'
  },
  {
    name: 'Honeycomb',
    category: 'Toffee',
    status: 'Out of stock',
    dairy: 'No'
  },
  {
    name: 'Donut',
    category: 'Pastry',
    dairy: 'Yes',
    status: 'Available'
  },
  {
    name: 'KitKat',
    category: 'Candy',
    dairy: 'Yes',
    status: 'Available'
  }
];

export const sortBy = [{ key: 'name', order: 'asc' }];

export function DEFAULT_HEADERS() {
  return [
    {
      title: 'Dessert',
      align: 'start' as const,
      key: 'name',
      sortable: false,
      removable: false
    },
    { title: 'Calories', key: 'calories', removable: true },
    { title: 'Fat(g)', key: 'fat', removable: true },
    { title: 'Carbs(g)', key: 'carbs', removable: true },
    { title: 'Protein(g)', key: 'protein', removable: true },
    { title: 'Iron(%)', key: 'iron', removable: true }
  ];
}

export const headerDesserts = [
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: 1
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: 1
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: 7
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: 8
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: 16
  },
  {
    name: 'Jelly bean',
    calories: 375,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: 0
  },
  {
    name: 'Lollipop',
    calories: 392,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: 2
  },
  {
    name: 'Honeycomb',
    calories: 408,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    iron: 45
  },
  {
    name: 'Donut',
    calories: 452,
    fat: 25,
    carbs: 51,
    protein: 4.9,
    iron: 22
  },
  {
    name: 'KitKat',
    calories: 518,
    fat: 26,
    carbs: 65,
    protein: 7,
    iron: 6
  }
];

export const slotHeaders = [
  { title: 'ID', key: 'id', align: 'start' as const },
  { title: 'Name', key: 'name' },
  { title: 'Dept', key: 'department' },
  { title: 'Role', key: 'role' },
  { title: 'Salary($)', key: 'salary', align: 'end' as const },
  { title: 'HireDate', key: 'hireDate' },
  { title: 'Hours/Wk', key: 'hoursPerWeek', align: 'end' as const },
  { title: 'Location', key: 'location' },
  { title: 'Status', key: 'status' },
  { title: 'Score', key: 'score', align: 'end' as const }
] as const;

export const employees = [
  {
    id: 'E001',
    name: 'Alice Johnson',
    department: 'Engineering',
    role: 'Software Dev',
    salary: 95000,
    hireDate: '2020-03-15',
    hoursPerWeek: 40,
    location: 'New York',
    status: 'Full-Time',
    score: 4.5
  },
  {
    id: 'E002',
    name: 'Bob Carter',
    department: 'Sales',
    role: 'Account Manager',
    salary: 72000,
    hireDate: '2019-11-01',
    hoursPerWeek: 35,
    location: 'Chicago',
    status: 'Full-Time',
    score: 4.2
  },
  {
    id: 'E003',
    name: 'Clara Diaz',
    department: 'HR',
    role: 'Recruiter',
    salary: 65000,
    hireDate: '2021-06-10',
    hoursPerWeek: 32,
    location: 'Remote',
    status: 'Part-Time',
    score: 4.0
  },
  {
    id: 'E004',
    name: 'David Lee',
    department: 'Engineering',
    role: 'DevOps Engineer',
    salary: 105000,
    hireDate: '2018-09-22',
    hoursPerWeek: 40,
    location: 'San Francisco',
    status: 'Full-Time',
    score: 4.7
  },
  {
    id: 'E005',
    name: 'Ella Smith',
    department: 'Marketing',
    role: 'Social Media Mgr',
    salary: 80000,
    hireDate: '2020-01-05',
    hoursPerWeek: 38,
    location: 'Los Angeles',
    status: 'Full-Time',
    score: 4.3
  }
];

export const vegetableheaders = [
  { title: 'Vegetable', key: 'name' },
  { title: 'Calories', key: 'calories' },
  { title: 'Fat(g)', key: 'fat' },
  { title: 'Carbs(g)', key: 'carbs' },
  { title: 'Protein(g)', key: 'protein' },
  { title: 'Iron(%)', key: 'iron' }
];

export const vegetableitems = [
  {
    name: 'Spinach',
    calories: 23,
    fat: 0.4,
    carbs: 3.6,
    protein: 2.9,
    iron: '15%'
  },
  {
    name: 'Kale',
    calories: 49,
    fat: 0.9,
    carbs: 8.8,
    protein: 4.3,
    iron: '16%'
  },
  {
    name: 'Broccoli',
    calories: 34,
    fat: 0.4,
    carbs: 6.6,
    protein: 2.8,
    iron: '6%'
  },
  {
    name: 'Brussels Sprouts',
    calories: 43,
    fat: 0.3,
    carbs: 8.9,
    protein: 3.4,
    iron: '9%'
  },
  {
    name: 'Avocado',
    calories: 160,
    fat: 15,
    carbs: 9,
    protein: 2,
    iron: '3%'
  }
];

export const toolGroupBy = [{ key: 'type', order: 'asc' }];

export const toolheaders = [
  {
    title: 'Tool Name',
    align: 'start' as const,
    sortable: false,
    key: 'name'
  },
  { title: 'Weight(kg)', key: 'weight' },
  { title: 'Length(cm)', key: 'length' },
  { title: 'Price($)', key: 'price' }
];

export const groupSummaryHeaders = [
  { title: 'Tool Name', sortable: false, key: 'name' },
  { title: 'Weight(kg)', key: 'weight', align: 'end' as const },
  { title: 'Length(cm)', key: 'length', align: 'end' as const },
  { title: 'Price($)', key: 'price', align: 'end' as const }
];

export const tools = [
  { name: 'Hammer', weight: 0.5, length: 30, price: 10, type: 'hand' },
  { name: 'Screwdriver', weight: 0.2, length: 20, price: 5, type: 'hand' },
  { name: 'Drill', weight: 1.5, length: 25, price: 50, type: 'power' },
  { name: 'Saw', weight: 0.7, length: 50, price: 15, type: 'hand' },
  { name: 'Tape Measure', weight: 0.3, length: 10, price: 8, type: 'measuring' },
  { name: 'Level', weight: 0.4, length: 60, price: 12, type: 'measuring' },
  { name: 'Wrench', weight: 0.6, length: 25, price: 10, type: 'hand' },
  { name: 'Pliers', weight: 0.3, length: 15, price: 7, type: 'hand' },
  { name: 'Sander', weight: 2.0, length: 30, price: 60, type: 'power' },
  { name: 'Multimeter', weight: 0.5, length: 15, price: 30, type: 'measuring' }
];

export const loadingitems = [
  { name: 'Chevrolet Camaro', year: 1967, engine: 'V8', horsepower: 375, torque: 415 },
  { name: 'Ford Mustang', year: 1965, engine: 'V8', horsepower: 271, torque: 312 },
  { name: 'Dodge Charger', year: 1968, engine: 'V8', horsepower: 425, torque: 490 },
  { name: 'Pontiac GTO', year: 1964, engine: 'V8', horsepower: 350, torque: 445 },
  { name: 'Plymouth Barracuda', year: 1964, engine: 'V8', horsepower: 330, torque: 425 },
  { name: 'Chevrolet Chevelle SS', year: 1970, engine: 'V8', horsepower: 450, torque: 500 },
  { name: 'Oldsmobile 442', year: 1971, engine: 'V8', horsepower: 340, torque: 440 },
  { name: 'Dodge Challenger', year: 1970, engine: 'V8', horsepower: 425, torque: 490 },
  { name: 'AMC Javelin', year: 1968, engine: 'V8', horsepower: 315, torque: 425 },
  { name: 'Mercury Cougar', year: 1967, engine: 'V8', horsepower: 335, torque: 427 }
];

export const actionHeaders = [
  { title: 'Title', key: 'title', align: 'start' as const },
  { title: 'Author', key: 'author' },
  { title: 'Genre', key: 'genre' },
  { title: 'Year', key: 'year', align: 'end' as const },
  { title: 'Pages', key: 'pages', align: 'end' as const },
  { title: 'Actions', key: 'actions', align: 'end' as const, sortable: false }
];

export const initialBooks = [
  { id: 1, title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'Fiction', year: 1960, pages: 281 },
  { id: 2, title: '1984', author: 'George Orwell', genre: 'Dystopian', year: 1949, pages: 328 },
  { id: 3, title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Fiction', year: 1925, pages: 180 },
  { id: 4, title: 'Sapiens', author: 'Yuval Noah Harari', genre: 'Non-Fiction', year: 2011, pages: 443 },
  { id: 5, title: 'Dune', author: 'Frank Herbert', genre: 'Sci-Fi', year: 1965, pages: 412 }
];

export const genreOptions = ['Fiction', 'Dystopian', 'Non-Fiction', 'Sci-Fi'];

export const expandableHeaders = [
  { width: 300, title: 'Title', key: 'title', align: 'start' as const, sortable: true },
  { width: 250, title: 'Director', key: 'director' },
  { width: 150, title: 'Genre', key: 'genre' },
  { width: 100, title: 'Year', key: 'year', align: 'end' as const },
  { width: 140, title: 'Runtime(min)', key: 'runtime', align: 'end' as const },
  { width: 1, key: 'data-table-expand', align: 'end' as const }
];

export const movies = [
  {
    title: 'The Shawshank Redemption',
    director: 'Frank Darabont',
    genre: 'Drama',
    year: 1994,
    runtime: 142,
    details: {
      synopsis: 'Two imprisoned men bond over years, finding solace and redemption through acts of decency.',
      cast: ['Tim Robbins', 'Morgan Freeman'],
      rating: 3.5
    }
  },
  {
    title: 'Inception',
    director: 'Christopher Nolan',
    genre: 'Sci-Fi',
    year: 2010,
    runtime: 148,
    details: {
      synopsis: 'A thief with the ability to enter dreams is tasked with stealing a secret from the subconscious.',
      cast: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt'],
      rating: 5
    }
  },
  {
    title: 'The Godfather',
    director: 'Francis Ford Coppola',
    genre: 'Crime',
    year: 1972,
    runtime: 175,
    details: {
      synopsis: 'The aging patriarch of a crime dynasty transfers control to his reluctant son.',
      cast: ['Marlon Brando', 'Al Pacino'],
      rating: 4.5
    }
  },
  {
    title: 'Pulp Fiction',
    director: 'Quentin Tarantino',
    genre: 'Crime',
    year: 1994,
    runtime: 154,
    details: {
      synopsis: 'Interwoven stories of criminals, violence, and redemption in Los Angeles.',
      cast: ['John Travolta', 'Samuel L. Jackson'],
      rating: 4.5
    }
  },
  {
    title: 'The Dark Knight',
    director: 'Christopher Nolan',
    genre: 'Action',
    year: 2008,
    runtime: 152,
    details: {
      synopsis:
        'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      cast: ['Christian Bale', 'Heath Ledger'],
      rating: 4
    }
  }
];
