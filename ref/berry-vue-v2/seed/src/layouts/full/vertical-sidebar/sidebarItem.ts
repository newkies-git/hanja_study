import {
  BrandGravatarIcon,
  MenuIcon,
  CircleIcon,
  ShapeIcon,
  CircleOffIcon,
  BoxMultipleIcon,
  BrandChromeIcon,
  HelpIcon,
  SitemapIcon
} from 'vue-tabler-icons';

export interface menu {
  header?: string;
  title?: string;
  icon?: object;
  to?: string;
  divider?: boolean;
  chip?: string;
  chipColor?: string;
  chipVariant?: string;
  chipIcon?: string;
  children?: menu[];
  disabled?: boolean;
  type?: string;
  subCaption?: string;
}

const sidebarItem: menu[] = [
  { header: 'Starterkit' },
  {
    title: 'Sample Page',
    icon: BrandChromeIcon,
    to: '/starter'
  },
  { divider: true },
  { header: 'Others' },
  {
    title: 'Multilevel',
    icon: MenuIcon,
    to: '#',
    children: [
      {
        title: 'Level 1',
        icon: CircleIcon,
        to: '/level1'
      },
      {
        title: 'Level 1',
        icon: CircleIcon,
        to: '/2level',
        children: [
          {
            title: 'Level 2',
            icon: CircleIcon,
            to: ''
          },
          {
            title: 'Level 2',
            icon: CircleIcon,
            to: '/2.2level',
            children: [
              {
                title: 'Level 3',
                icon: CircleIcon,
                to: ''
              }
            ]
          }
        ]
      }
    ]
  },
  {
    title: 'Disabled Menu',
    icon: CircleOffIcon,
    disabled: true,
    to: ''
  },
  {
    title: 'Oval Chip',
    icon: CircleIcon,
    chip: '9',
    chipColor: 'primary',
    to: ''
  },
  {
    title: 'Avatar',
    icon: BrandGravatarIcon,
    chip: 'coded',
    chipColor: 'primary',
    chipIcon: '$accountCircle',
    to: ''
  },
  {
    title: 'Outline',
    icon: ShapeIcon,
    chip: 'outline',
    chipColor: 'primary',
    chipVariant: 'outlined',
    to: ''
  },
  {
    title: 'Sub Caption',
    icon: BoxMultipleIcon,
    subCaption: 'caption title',
    to: ''
  },
  { divider: true },

  {
    title: 'Documentation',
    icon: HelpIcon,
    to: 'https://codedthemes.gitbook.io/berry-vuetify/',
    type: 'external'
  },
  {
    title: 'Road Map',
    icon: SitemapIcon,
    to: 'https://codedthemes.gitbook.io/berry-vuetify/roadmap',
    type: 'external'
  }
];

export default sidebarItem;
