// Data for Data & Display Table page

export const cpuHeaders = [
  {
    title: 'CPU Model',
    align: 'start' as const,
    key: 'name'
  },
  {
    title: 'Cores',
    align: 'end' as const,
    key: 'cores'
  },
  {
    title: 'Threads',
    align: 'end' as const,
    key: 'threads'
  },
  {
    title: 'Base Clock',
    align: 'end' as const,
    key: 'baseClock'
  },
  {
    title: 'Boost Clock',
    align: 'end' as const,
    key: 'boostClock'
  },
  {
    title: 'TDP (W)',
    align: 'end' as const,
    key: 'tdp'
  }
];

export const cpuItems = [
  {
    name: 'Intel Core i9-11900K',
    cores: 8,
    threads: 16,
    baseClock: '3.5 GHz',
    boostClock: '5.3 GHz',
    tdp: '125W'
  },
  {
    name: 'AMD Ryzen 9 5950X',
    cores: 16,
    threads: 32,
    baseClock: '3.4 GHz',
    boostClock: '4.9 GHz',
    tdp: '105W'
  },
  {
    name: 'Intel Core i7-10700K',
    cores: 8,
    threads: 16,
    baseClock: '3.8 GHz',
    boostClock: '5.1 GHz',
    tdp: '125W'
  },
  {
    name: 'AMD Ryzen 5 5600X',
    cores: 6,
    threads: 12,
    baseClock: '3.7 GHz',
    boostClock: '4.6 GHz',
    tdp: '65W'
  },
  {
    name: 'Intel Core i5-10600K',
    cores: 6,
    threads: 12,
    baseClock: '4.1 GHz',
    boostClock: '4.8 GHz',
    tdp: '125W'
  },
  {
    name: 'AMD Ryzen 7 5800X',
    cores: 8,
    threads: 16,
    baseClock: '3.8 GHz',
    boostClock: '4.7 GHz',
    tdp: '105W'
  },
  {
    name: 'Intel Core i3-10100',
    cores: 4,
    threads: 8,
    baseClock: '3.6 GHz',
    boostClock: '4.3 GHz',
    tdp: '65W'
  },
  {
    name: 'AMD Ryzen 3 3300X',
    cores: 4,
    threads: 8,
    baseClock: '3.8 GHz',
    boostClock: '4.3 GHz',
    tdp: '65W'
  },
  {
    name: 'Intel Pentium Gold G6400',
    cores: 2,
    threads: 4,
    baseClock: '4.0 GHz',
    tdp: '58W'
  },
  {
    name: 'AMD Athlon 3000G',
    cores: 2,
    threads: 4,
    baseClock: '3.5 GHz',
    tdp: '35W'
  }
];

export const gpuItems = [
  {
    name: 'Nebula GTX 3080',
    image: '1.png',
    price: 699.99,
    rating: 5,
    stock: true
  },
  {
    name: 'Galaxy RTX 3080',
    image: '2.png',
    price: 799.99,
    rating: 4,
    stock: false
  },
  {
    name: 'Orion RX 6800 XT',
    image: '3.png',
    price: 649.99,
    rating: 3,
    stock: true
  },
  {
    name: 'Vortex RTX 3090',
    image: '4.png',
    price: 1499.99,
    rating: 4,
    stock: true
  },
  {
    name: 'Cosmos GTX 1660 Super',
    image: '5.png',
    price: 299.99,
    rating: 4,
    stock: false
  }
];

export const paginationHeaders = [
  {
    align: 'start' as const,
    key: 'name',
    sortable: false,
    title: 'Dessert (100g serving)'
  },
  { title: 'Calories', key: 'calories' },
  { title: 'Fat (g)', key: 'fat' },
  { title: 'Carbs (g)', key: 'carbs' },
  { title: 'Protein (g)', key: 'protein' },
  { title: 'Iron (%)', key: 'iron' }
];

// Base dessert data
const baseDesserts = [
  { name: 'Frozen Yogurt', calories: 159, fat: 6, carbs: 24, protein: 4, iron: 1 },
  { name: 'Ice cream sandwich', calories: 237, fat: 9, carbs: 37, protein: 4.3, iron: 1 },
  { name: 'Eclair', calories: 262, fat: 16, carbs: 23, protein: 6, iron: 7 },
  { name: 'Cupcake', calories: 305, fat: 3.7, carbs: 67, protein: 4.3, iron: 8 },
  { name: 'Gingerbread', calories: 356, fat: 16, carbs: 49, protein: 3.9, iron: 16 },
  { name: 'Jelly bean', calories: 375, fat: 0, carbs: 94, protein: 0, iron: 0 },
  { name: 'Lollipop', calories: 392, fat: 0.2, carbs: 98, protein: 0, iron: 2 },
  { name: 'Honeycomb', calories: 408, fat: 3.2, carbs: 87, protein: 6.5, iron: 45 },
  { name: 'Donut', calories: 452, fat: 25, carbs: 51, protein: 4.9, iron: 22 },
  { name: 'KitKat', calories: 518, fat: 26, carbs: 65, protein: 7, iron: 6 }
];

// Base dessert headers
const baseDessertHeaders = [
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    key: 'name'
  },
  { title: 'Calories', align: 'end' as const, key: 'calories' },
  { title: 'Fat (g)', align: 'end' as const, key: 'fat' },
  { title: 'Carbs (g)', align: 'end' as const, key: 'carbs' },
  { title: 'Protein (g)', align: 'end' as const, key: 'protein' },
  { title: 'Iron (%)', align: 'end' as const, key: 'iron' }
];

export const paginationDesserts = baseDesserts;

export const selectableHeaders = baseDessertHeaders;

export const selectableDesserts = [
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: 1,
    selectable: false
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: 1,
    selectable: true
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: 7,
    selectable: true
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: 8,
    selectable: false
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: 16,
    selectable: true
  },
  {
    name: 'Jelly bean',
    calories: 375,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: 0,
    selectable: true
  },
  {
    name: 'Lollipop',
    calories: 392,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: 2,
    selectable: true
  },
  {
    name: 'Honeycomb',
    calories: 408,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    iron: 45,
    selectable: false
  },
  {
    name: 'Donut',
    calories: 452,
    fat: 25,
    carbs: 51,
    protein: 4.9,
    iron: 22,
    selectable: true
  },
  {
    name: 'KitKat',
    calories: 518,
    fat: 26,
    carbs: 65,
    protein: 7,
    iron: 6,
    selectable: true
  }
];

export const customSelectDesserts = baseDesserts;

export const selectedHeaders = baseDessertHeaders;

export const selectedDesserts = baseDesserts;

export const selectStrategiesHeaders = baseDessertHeaders;

export const selectStrategiesDesserts = baseDesserts;

export const basicSortingHeaders = [
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    sortable: false,
    key: 'name'
  },
  { title: 'Calories', key: 'calories' },
  { title: 'Fat (g)', key: 'fat' },
  { title: 'Carbs (g)', key: 'carbs' },
  { title: 'Protein (g)', key: 'protein' },
  { title: 'Iron (%)', key: 'iron' }
];

export const basicSortingDesserts = [
  {
    name: 'Frozen Yogurt',
    calories: 200,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: '1%'
  },
  {
    name: 'Ice cream sandwich',
    calories: 200,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: '1%'
  },
  {
    name: 'Eclair',
    calories: 300,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: '7%'
  },
  {
    name: 'Cupcake',
    calories: 300,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: '8%'
  },
  {
    name: 'Gingerbread',
    calories: 400,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: '16%'
  },
  {
    name: 'Jelly bean',
    calories: 400,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: '0%'
  },
  {
    name: 'Lollipop',
    calories: 400,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: '2%'
  },
  {
    name: 'Honeycomb',
    calories: 400,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    iron: '45%'
  },
  {
    name: 'Donut',
    calories: 500,
    fat: 25,
    carbs: 51,
    protein: 4.9,
    iron: '22%'
  },
  {
    name: 'KitKat',
    calories: 500,
    fat: 26,
    carbs: 65,
    protein: 7,
    iron: '6%'
  }
];

export const multiSortHeaders = [
  {
    title: 'Dessert (100g serving)',
    align: 'start' as const,
    sortable: false,
    key: 'name'
  },
  { title: 'Calories', key: 'calories' },
  { title: 'Fat (g)', key: 'fat' },
  { title: 'Carbs (g)', key: 'carbs' },
  { title: 'Protein (g)', key: 'protein' },
  { title: 'Iron (%)', key: 'iron' }
];

export const multiSortDesserts = [
  {
    name: 'Frozen Yogurt',
    calories: 200,
    fat: 6,
    carbs: 24,
    protein: 4,
    iron: 1
  },
  {
    name: 'Ice cream sandwich',
    calories: 200,
    fat: 9,
    carbs: 37,
    protein: 4.3,
    iron: 1
  },
  {
    name: 'Eclair',
    calories: 300,
    fat: 16,
    carbs: 23,
    protein: 6,
    iron: 7
  },
  {
    name: 'Cupcake',
    calories: 300,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    iron: 8
  },
  {
    name: 'Gingerbread',
    calories: 400,
    fat: 16,
    carbs: 49,
    protein: 3.9,
    iron: 16
  },
  {
    name: 'Jelly bean',
    calories: 400,
    fat: 0,
    carbs: 94,
    protein: 0,
    iron: 0
  },
  {
    name: 'Lollipop',
    calories: 400,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    iron: 2
  },
  {
    name: 'Honeycomb',
    calories: 400,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    iron: 45
  },
  {
    name: 'Donut',
    calories: 500,
    fat: 25,
    carbs: 51,
    protein: 4.9,
    iron: 22
  },
  {
    name: 'KitKat',
    calories: 500,
    fat: 26,
    carbs: 65,
    protein: 7,
    iron: 6
  }
];

export const sortItems = [
  {
    name: 'Great Pyramid of Giza',
    location: 'Egypt',
    constructed: '2584-2561 BC',
    description: 'The oldest and largest of the three pyramids in the Giza pyramid complex.'
  },
  {
    name: 'Hanging Gardens of Babylon',
    location: 'Iraq',
    constructed: '600 BC',
    description: 'An ascending series of tiered gardens, said to have been built in ancient Babylon.'
  },
  {
    name: 'Statue of Zeus at Olympia',
    location: 'Greece',
    constructed: '435 BC',
    description: 'A giant seated figure of Zeus, made by the sculptor Phidias.'
  },
  {
    name: 'Temple of Artemis at Ephesus',
    location: 'Turkey',
    constructed: '550 BC',
    description: 'A large temple dedicated to the goddess Artemis, one of the Seven Wonders of the Ancient World.'
  },
  {
    name: 'Mausoleum at Halicarnassus',
    location: 'Turkey',
    constructed: '351 BC',
    description: 'A tomb built for Mausolus, a satrap of the Persian Empire.'
  },
  {
    name: 'Colossus of Rhodes',
    location: 'Greece',
    constructed: '292-280 BC',
    description: 'A statue of the Greek sun-god Helios, erected in the city of Rhodes.'
  },
  {
    name: 'Lighthouse of Alexandria',
    location: 'Egypt',
    constructed: '280 BC',
    description: 'A lighthouse built by the Ptolemaic Kingdom on the island of Pharos.'
  },
  {
    name: 'Great Wall of China',
    location: 'China',
    constructed: '7th century BC - 1644 AD',
    description: 'A series of fortifications made of stone, brick, and other materials.'
  },
  {
    name: 'Petra',
    location: 'Jordan',
    constructed: '312 BC',
    description: 'A historical city known for its rock-cut architecture and water conduit system.'
  },
  {
    name: 'Taj Mahal',
    location: 'India',
    constructed: '1632-1653 AD',
    description: 'An ivory-white marble mausoleum on the south bank of the Yamuna river.'
  },
  { name: 'Machu Picchu', location: 'Peru', constructed: '1450 AD', description: 'An Incan citadel set high in the Andes Mountains.' },
  {
    name: 'Chichen Itza',
    location: 'Mexico',
    constructed: '600 AD',
    description: 'A large pre-Columbian archaeological site built by the Maya people.'
  },
  {
    name: 'Roman Colosseum',
    location: 'Italy',
    constructed: '70-80 AD',
    description: 'An oval amphitheatre in the centre of the city of Rome.'
  },
  {
    name: 'Stonehenge',
    location: 'United Kingdom',
    constructed: '3000 BC - 2000 BC',
    description: 'A prehistoric monument consisting of a ring of standing stones.'
  },
  {
    name: 'Angkor Wat',
    location: 'Cambodia',
    constructed: '12th century AD',
    description: 'The largest religious monument in the world, originally constructed as a Hindu temple.'
  },
  {
    name: 'Moai Statues of Easter Island',
    location: 'Chile',
    constructed: '1250-1500 AD',
    description: 'Monolithic human figures carved by the Rapa Nui people on Easter Island.'
  },
  {
    name: 'Hagia Sophia',
    location: 'Turkey',
    constructed: '537 AD',
    description: 'A former Greek Orthodox Christian patriarchal basilica, later an Ottoman imperial mosque and now a museum.'
  },
  { name: 'Alhambra', location: 'Spain', constructed: '13th century AD', description: 'A palace and fortress complex located in Granada.' },
  {
    name: 'Forbidden City',
    location: 'China',
    constructed: '1406-1420 AD',
    description: 'A palace complex in central Beijing, serving as the home of emperors and their households.'
  },
  {
    name: 'Christ the Redeemer',
    location: 'Brazil',
    constructed: '1922-1931 AD',
    description: 'An Art Deco statue of Jesus Christ in Rio de Janeiro.'
  },
  {
    name: 'Acropolis of Athens',
    location: 'Greece',
    constructed: '5th century BC',
    description: 'An ancient citadel located on a rocky outcrop above the city of Athens.'
  },
  {
    name: 'Terracotta Army',
    location: 'China',
    constructed: '246-206 BC',
    description: 'A collection of terracotta sculptures depicting the armies of Qin Shi Huang, the first Emperor of China.'
  },
  {
    name: 'Parthenon',
    location: 'Greece',
    constructed: '447-438 BC',
    description: 'A former temple on the Athenian Acropolis, dedicated to the goddess Athena.'
  },
  {
    name: 'Tower of London',
    location: 'United Kingdom',
    constructed: '1078 AD',
    description: 'A historic castle located on the north bank of the River Thames in central London.'
  },
  {
    name: 'Neuschwanstein Castle',
    location: 'Germany',
    constructed: '1869-1886 AD',
    description: 'A 19th-century Romanesque Revival palace on a rugged hill above the village of Hohenschwangau.'
  }
];
// sort by raw function
export function sortRaw(a: { location: string; constructed: string }, b: { location: string; constructed: string }) {
  if (a.location < b.location) return -1;
  if (a.location > b.location) return 1;

  const dateA = a.constructed.split('-').pop()?.trim() || '';
  const dateB = b.constructed.split('-').pop()?.trim() || '';

  return dateA.localeCompare(dateB, undefined, { numeric: true, sensitivity: 'base' });
}

export const sortHeaders = [
  { title: 'Name', key: 'name' },
  { title: 'Location', key: 'location', sortRaw },
  { title: 'Constructed', key: 'constructed' },
  { title: 'Description', key: 'description' }
];
