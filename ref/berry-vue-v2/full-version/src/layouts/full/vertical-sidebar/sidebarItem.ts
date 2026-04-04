import {
  BrandGravatarIcon,
  MenuIcon,
  CircleIcon,
  CircleOffIcon,
  BoxMultipleIcon,
  FormsIcon,
  ChartDotsIcon,
  PictureInPictureIcon,
  ClipboardCheckIcon,
  WindmillIcon,
  Receipt2Icon,
  TypographyIcon,
  ShadowIcon,
  PaletteIcon,
  LayoutGridAddIcon,
  BrandFramerIcon,
  KeyIcon,
  BugIcon,
  TableIcon,
  BrushIcon,
  ToolsIcon,
  BasketIcon,
  MessagesIcon,
  UserCheckIcon,
  NfcIcon,
  MailIcon,
  LayoutKanbanIcon,
  CalendarIcon,
  DashboardIcon,
  DeviceAnalyticsIcon,
  ChartArcsIcon,
  ClipboardIcon,
  ChartInfographicIcon,
  BellRingingIcon,
  PhoneCallIcon,
  QuestionMarkIcon,
  ShieldLockIcon,
  BrandChromeIcon,
  HelpIcon,
  SitemapIcon,
  TablePlusIcon
} from 'vue-tabler-icons';

export interface menu {
  id?: string;
  header?: string;
  title?: string;
  icon?: object;
  to?: string;
  getURL?: boolean;
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
  { header: 'Dashboard' },
  {
    id: 'default',
    title: 'Default',
    icon: DashboardIcon,
    to: '/dashboard/default'
  },
  {
    id: 'analytics',
    title: 'Analytics',
    icon: DeviceAnalyticsIcon,
    to: '/dashboard/analytics'
  },

  { header: 'Widget' },
  {
    id: 'statistics',
    title: 'Statistics',
    icon: ChartArcsIcon,
    to: '/widget/statistics'
  },
  {
    id: 'data',
    title: 'Data',
    icon: ClipboardIcon,
    to: '/widget/data'
  },
  {
    id: 'chart',
    title: 'Chart',
    icon: ChartInfographicIcon,
    to: '/widget/chart'
  },

  { divider: true },
  { header: 'Applications' },
  {
    title: 'Users',
    icon: UserCheckIcon,
    to: '/app/user',
    children: [
      {
        id: 'socialprofile',
        title: 'Social Profile',
        icon: CircleIcon,
        to: '/app/user/social/posts'
      },
      {
        title: 'Account Profile',
        icon: CircleIcon,
        to: '/app/user/account-profile',
        children: [
          {
            id: 'profile01',
            title: 'Profile 01',
            icon: CircleIcon,
            to: '/app/user/account-profile/profile1'
          },
          {
            id: 'profile02',
            title: 'Profile 02',
            icon: CircleIcon,
            to: '/app/user/account-profile/profile2'
          },
          {
            id: 'profile03',
            title: 'Profile 03',
            icon: CircleIcon,
            to: '/app/user/account-profile/profile3'
          }
        ]
      },
      {
        title: 'Cards',
        icon: CircleIcon,
        to: '/app/user/card',
        children: [
          {
            id: 'style01',
            title: 'Style 01',
            icon: CircleIcon,
            to: '/app/user/card/card1'
          },
          {
            id: 'style02',
            title: 'Style 02',
            icon: CircleIcon,
            to: '/app/user/card/card2'
          },
          {
            id: 'style03',
            title: 'Style 03',
            icon: CircleIcon,
            to: '/app/user/card/card3'
          }
        ]
      },
      {
        title: 'List',
        icon: CircleIcon,
        to: '/app/user/list',
        children: [
          {
            id: 'liststyle01',
            title: 'Style 01',
            icon: CircleIcon,
            to: '/app/user/list1'
          },
          {
            id: 'liststyle02',
            title: 'Style 02',
            icon: CircleIcon,
            to: '/app/user/list2'
          }
        ]
      }
    ]
  },
  {
    title: 'Customer',
    icon: BasketIcon,
    to: '/customer/',
    children: [
      {
        id: 'customerlist',
        title: 'Customer List',
        icon: CircleIcon,
        to: '/app/customer/customerlist'
      },
      {
        id: 'createinvoice',
        title: 'Create Invoice',
        icon: CircleIcon,
        to: '/app/customer/create-invoice'
      },
      {
        id: 'orderdetails',
        title: 'Order Details',
        icon: CircleIcon,
        to: '/app/customer/order-details'
      },
      {
        id: 'orderlist',
        title: 'Order List',
        icon: CircleIcon,
        to: '/app/customer/orderlist'
      },
      {
        id: 'productlist',
        title: 'Product List',
        icon: CircleIcon,
        to: '/app/customer/productlist'
      },
      {
        id: 'productreview',
        title: 'Product Review',
        icon: CircleIcon,
        to: '/app/customer/productreview'
      }
    ]
  },
  {
    id: 'chat',
    title: 'Chat',
    icon: MessagesIcon,
    to: '/app/chats'
  },
  {
    id: 'kanban',
    title: 'Kanban',
    icon: LayoutKanbanIcon,
    to: '/app/kanban'
  },
  {
    id: 'mail',
    title: 'Mail',
    icon: MailIcon,
    to: '/app/mail'
  },
  {
    id: 'calendar',
    title: 'Calendar',
    icon: CalendarIcon,
    to: '/app/calendar'
  },
  {
    title: 'Contact',
    icon: NfcIcon,
    to: '/app/contacts',
    children: [
      {
        id: 'contactcard',
        title: 'Card',
        icon: CircleIcon,
        to: '/app/contact/c-card'
      },
      {
        id: 'contactlist',
        title: 'List',
        icon: CircleIcon,
        to: '/app/contact/c-list'
      }
    ]
  },
  {
    title: 'E-Commerce',
    icon: BasketIcon,
    to: '/ecommerce/',
    children: [
      {
        id: 'products',
        title: 'Products',
        icon: CircleIcon,
        to: '/ecommerce/products'
      },
      {
        id: 'productdetail',
        title: 'Product Detail',
        icon: CircleIcon,
        to: '/ecommerce/product/detail/1'
      },
      {
        id: 'productlist',
        title: 'Product List',
        icon: CircleIcon,
        to: '/ecommerce/productlist'
      },

      {
        id: 'checkout',
        title: 'Checkout',
        icon: CircleIcon,
        to: '/ecommerce/checkout'
      }
    ]
  },
  { divider: true },
  { header: 'Forms' },
  {
    title: 'Components',
    icon: PictureInPictureIcon,
    to: '/ui-elements/',
    children: [
      {
        id: 'autocomplete',
        title: 'Autocomplete',
        icon: CircleIcon,
        to: '/ui-elements/autocomplete'
      },
      {
        id: 'buttons',
        title: 'Buttons',
        icon: CircleIcon,
        to: '/ui-elements/buttons'
      },
      {
        id: 'bottomsheet',
        title: 'Bottom Sheet',
        icon: CircleIcon,
        to: '/ui-elements/bottom-sheet'
      },
      {
        id: 'checkbox',
        title: 'Checkbox',
        icon: CircleIcon,
        to: '/ui-elements/checkbox'
      },
      {
        id: 'radio',
        title: 'Radio',
        icon: CircleIcon,
        to: '/ui-elements/radio'
      },
      {
        id: 'textfield',
        title: 'TextField',
        icon: CircleIcon,
        to: '/ui-elements/textfield'
      },
      {
        id: 'fileinput',
        title: 'File Input',
        icon: CircleIcon,
        to: '/ui-elements/file-input'
      },
      {
        id: 'numberinput',
        title: 'Number Input',
        icon: CircleIcon,
        to: '/ui-elements/number-input'
      },
      {
        id: 'slider',
        title: 'Slider',
        icon: CircleIcon,
        to: '/ui-elements/slider'
      },
      {
        id: 'switch',
        title: 'Switch',
        icon: CircleIcon,
        to: '/ui-elements/switch'
      },
      {
        id: 'rangeSlider',
        title: 'Range Slider',
        icon: CircleIcon,
        to: '/ui-elements/range-slider'
      },
      {
        id: 'otpinput',
        title: 'OTP Input',
        icon: CircleIcon,
        to: '/ui-elements/otp-input'
      }
    ]
  },

  {
    title: 'Plugins',
    icon: FormsIcon,
    to: '/forms/radio',
    children: [
      {
        id: 'editor',
        title: 'Editor',
        icon: CircleIcon,
        to: '/forms/plugins/editor'
      },
      {
        id: 'dropzone',
        title: 'Dropzone',
        icon: CircleIcon,
        to: '/forms/plugins/dropzone'
      },
      {
        id: 'captcha',
        title: 'Captcha',
        icon: CircleIcon,
        to: '/captcha'
      },
      {
        id: 'clipboard',
        title: 'Clipboard',
        icon: CircleIcon,
        to: '/forms/plugins/clipboard'
      },
      {
        id: 'modal',
        title: 'Modal',
        icon: CircleIcon,
        to: '/forms/plugins/modal'
      },
      {
        id: 'tooltip',
        title: 'Tooltip',
        icon: CircleIcon,
        to: '/forms/plugins/tooltip'
      }
    ]
  },

  {
    title: 'Layouts',
    icon: FormsIcon,
    to: '/forms/layouts',
    children: [
      {
        id: 'layouts',
        title: 'Layouts',
        icon: CircleIcon,
        to: '/forms/layouts/layouts'
      },
      {
        id: 'multicolumns',
        title: 'Multi Columns Form',
        icon: CircleIcon,
        to: '/forms/layouts/multi-column-forms'
      },
      {
        id: 'actionbar',
        title: 'Action Bar',
        icon: CircleIcon,
        to: '/forms/layouts/action-bar'
      },
      {
        id: 'stickybar',
        title: 'Sticky Action Bar',
        icon: CircleIcon,
        to: '/forms/layouts/sticky-action-bar'
      }
    ]
  },
  {
    title: 'Tables',
    icon: TableIcon,
    to: '/forms/tables',
    children: [
      {
        id: 'basictable',
        title: 'Basic Table',
        icon: CircleIcon,
        to: '/tables/tbl-basic'
      },
      {
        id: 'darktable',
        title: 'Dark Table',
        icon: CircleIcon,
        to: '/tables/tbl-dark'
      },
      {
        id: 'densitytable',
        title: 'Density Table',
        icon: CircleIcon,
        to: '/tables/tbl-density'
      },
      {
        id: 'heighttable',
        title: 'Height Table',
        icon: CircleIcon,
        to: '/tables/tbl-height'
      },
      {
        id: 'fixedheadertable',
        title: 'Fixed Header Table',
        icon: CircleIcon,
        to: '/tables/tbl-fixed-header'
      }
    ]
  },
  {
    title: 'Charts',
    icon: ChartDotsIcon,
    to: '/forms/radio',
    children: [
      {
        id: 'orgcharts',
        title: 'Org Charts',
        icon: CircleIcon,
        to: '/charts/orgchart'
      },
      {
        id: 'apexcharts',
        title: 'Apex Charts',
        icon: CircleIcon,
        to: '/charts/apex-chart'
      },
      {
        id: 'piechart',
        title: 'Pie Charts',
        icon: CircleIcon,
        to: '/charts/pie-chart'
      },
      {
        id: 'sparklines',
        title: 'Sparklines',
        icon: CircleIcon,
        to: '/charts/sparklines'
      }
    ]
  },
  {
    id: 'formvalidation',
    title: 'Form Validation',
    icon: ClipboardCheckIcon,
    to: '/forms/formvalidation'
  },
  { divider: true },
  { header: 'UI Elements' },
  {
    title: 'Basic',
    icon: BrushIcon,
    to: '/basic/',
    subCaption: '8+ Components',
    children: [
      {
        id: 'accordion',
        title: 'Accordion',
        icon: CircleIcon,
        to: '/basic/expansion-panel'
      },
      {
        id: 'avatar',
        title: 'Avatar',
        icon: CircleIcon,
        to: '/basic/avatar'
      },
      {
        id: 'parallax',
        title: 'Parallax',
        icon: CircleIcon,
        to: '/basic/parallax'
      },
      {
        id: 'badges',
        title: 'Badges',
        icon: CircleIcon,
        to: '/basic/badges'
      },
      {
        id: 'breadcrumb',
        title: 'Breadcrumb',
        icon: CircleIcon,
        to: '/basic/breadcrumb'
      },
      {
        id: 'cards',
        title: 'Cards',
        icon: CircleIcon,
        to: '/basic/cards'
      },
      {
        id: 'chip',
        title: 'Chip',
        icon: CircleIcon,
        to: '/basic/chip'
      },
      {
        id: 'list',
        title: 'List',
        icon: CircleIcon,
        to: '/basic/uilist'
      },
      {
        id: 'tabs',
        title: 'Tabs',
        icon: CircleIcon,
        to: '/basic/tabs'
      }
    ]
  },
  {
    title: 'Advance',
    icon: ToolsIcon,
    to: '/basic/tabs',
    children: [
      {
        id: 'alert',
        title: 'Alert',
        icon: CircleIcon,
        to: '/advance/alert'
      },
      {
        id: 'empty state',
        title: 'Empty State',
        icon: CircleIcon,
        to: '/advance/emptystate'
      },
      {
        id: 'pagination',
        title: 'Pagination',
        icon: CircleIcon,
        to: '/advance/pagination'
      },
      {
        id: 'progress',
        title: 'Progress',
        icon: CircleIcon,
        to: '/advance/progress'
      },
      {
        id: 'floatingaction',
        title: 'Floating Action',
        icon: CircleIcon,
        to: '/advance/floatingaction'
      },
      {
        id: 'steppers',
        title: 'Steppers',
        icon: CircleIcon,
        to: '/advance/steppers'
      },
      {
        id: 'ratings',
        title: 'Ratings',
        icon: CircleIcon,
        to: '/advance/ratings'
      },
      {
        id: 'snackbar',
        title: 'Snackbar',
        icon: CircleIcon,
        to: '/advance/snackbar'
      },
      {
        id: 'maskinput',
        title: 'Mask inputs',
        icon: CircleIcon,
        to: '/advance/mask-input'
      },
      {
        id: 'timeline',
        title: 'Timeline',
        icon: CircleIcon,
        to: '/advance/timeline'
      },
      {
        id: 'speeddial',
        title: 'Speed Dial',
        icon: CircleIcon,
        to: '/advance/speeddial'
      },
      {
        id: 'treeview',
        title: 'Treeview',
        icon: CircleIcon,
        to: '/advance/treeview'
      },
      {
        id: 'fileupload',
        title: 'File upload',
        icon: CircleIcon,
        to: '/advance/fileupload'
      },
      {
        id: 'buttontoggle',
        title: 'Button Toggle',
        icon: CircleIcon,
        to: '/advance/btn-toggle'
      },
      {
        id: 'datepicker',
        title: 'Date pickers',
        icon: CircleIcon,
        to: '/advance/datepicker'
      },
      {
        id: 'timepicker',
        title: 'Time pickers',
        icon: CircleIcon,
        to: '/advance/timepicker'
      },
      {
        id: 'chipgroups',
        title: 'Chip groups',
        icon: CircleIcon,
        to: '/advance/chip-group'
      },
      {
        id: 'dataiterator',
        title: 'Data Iterators',
        icon: CircleIcon,
        to: '/advance/data-iterator'
      }
    ]
  },
  {
    title: 'Datatables',
    icon: TablePlusIcon,
    to: '/datatables',
    children: [
      {
        id: 'basicdatatable',
        title: 'Basic',
        icon: CircleIcon,
        to: '/advance/basic-datatable'
      },
      {
        id: 'data&display',
        title: 'Data & Display',
        icon: CircleIcon,
        to: '/advance/data-display-datatable'
      },
      {
        id: 'serverSideTable',
        title: 'Server side',
        icon: CircleIcon,
        to: '/advance/server-side-datatable'
      }
    ]
  },
  { divider: true },
  { header: 'Pages' },
  {
    title: 'Authentication',
    icon: KeyIcon,
    to: '/auth',
    children: [
      {
        title: 'Auth 1',
        icon: CircleIcon,
        to: '/auth/login',
        children: [
          {
            id: 'login1',
            title: 'Login',
            icon: CircleIcon,
            to: '/auth1/login1'
          },
          {
            id: 'register1',
            title: 'Register',
            icon: CircleIcon,
            to: '/auth1/register1'
          },
          {
            id: 'forgotpassword1',
            title: 'Forgot Password',
            icon: CircleIcon,
            to: '/auth1/forgotpwd1'
          },
          {
            id: 'checkmail1',
            title: 'Check Mail',
            icon: CircleIcon,
            to: '/auth1/check-mail1'
          },
          {
            id: 'resetpassword1',
            title: 'Reset Password',
            icon: CircleIcon,
            to: '/auth1/reset-pwd1'
          },
          {
            id: 'codeverification1',
            title: 'Code Verification',
            icon: CircleIcon,
            to: '/auth1/code-verification'
          }
        ]
      },
      {
        title: 'Auth 2',
        icon: CircleIcon,
        to: '/auth/login',
        children: [
          {
            id: 'login2',
            title: 'Login 2',
            icon: CircleIcon,
            to: '/auth2/login2'
          },
          {
            id: 'register2',
            title: 'Register 2',
            icon: CircleIcon,
            to: '/auth2/register2'
          },
          {
            id: 'forgotpassword2',
            title: 'Forgot Password 2',
            icon: CircleIcon,
            to: '/auth2/forgotpwd2'
          },
          {
            id: 'checkmail2',
            title: 'Check Mail 2',
            icon: CircleIcon,
            to: '/auth2/check-mail2'
          },
          {
            id: 'resetpassword2',
            title: 'Reset Password 2',
            icon: CircleIcon,
            to: '/auth2/reset-pwd2'
          },
          {
            id: 'codeverification2',
            title: 'Code Verification 2',
            icon: CircleIcon,
            to: '/auth2/code-verification'
          }
        ]
      },
      {
        title: 'Auth 3',
        icon: CircleIcon,
        to: '/auth/login',
        children: [
          {
            id: 'login3',
            title: 'Login 3',
            icon: CircleIcon,
            to: '/auth3/login3'
          },
          {
            id: 'register3',
            title: 'Register 3',
            icon: CircleIcon,
            to: '/auth3/register3'
          },
          {
            id: 'forgotpassword3',
            title: 'Forgot Password 3',
            icon: CircleIcon,
            to: '/auth3/forgotpwd3'
          },
          {
            id: 'checkmail3',
            title: 'Check Mail 3',
            icon: CircleIcon,
            to: '/auth3/check-mail3'
          },
          {
            id: 'resetpassword3',
            title: 'Reset Password 3',
            icon: CircleIcon,
            to: '/auth3/reset-pwd3'
          },
          {
            id: 'codeverification3',
            title: 'Code Verification 3',
            icon: CircleIcon,
            to: '/auth3/code-verification'
          }
        ]
      }
    ]
  },
  {
    title: 'Pricing',
    icon: Receipt2Icon,
    to: '/starter',
    children: [
      {
        id: 'pricing1',
        title: 'Pricing 1',
        icon: CircleIcon,
        to: '/pricing/pricing1'
      },
      {
        id: 'pricing2',
        title: 'Pricing 2',
        icon: CircleIcon,
        to: '/pricing/pricing2'
      }
    ]
  },
  {
    title: 'Maintenance',
    icon: BugIcon,
    to: '/maintenenace',
    children: [
      {
        id: 'error404',
        title: 'Error 404',
        icon: CircleIcon,
        to: '/maintenance/error'
      },
      {
        id: 'cominingsoon1',
        title: 'Coming soon1',
        icon: CircleIcon,
        to: '/maintenance/comingsoon'
      },
      {
        id: 'construction',
        title: 'Under Construction',
        icon: CircleIcon,
        to: '/underconstruction'
      }
    ]
  },
  {
    title: 'Landing page',
    icon: BellRingingIcon,
    getURL: true,
    to: '',
    type: 'external'
  },
  {
    title: 'Contact Us',
    icon: PhoneCallIcon,
    getURL: true,
    to: 'contact-us',
    type: 'external'
  },
  {
    title: 'FAQs',
    icon: QuestionMarkIcon,
    getURL: true,
    to: 'faq',
    type: 'external'
  },
  {
    title: 'Privacy Policy',
    icon: ShieldLockIcon,
    getURL: true,
    to: 'privacy-policy',
    type: 'external'
  },
  { divider: true },
  { header: 'Utilities' },
  {
    id: 'typography',
    title: 'Typography',
    icon: TypographyIcon,
    to: '/utils/typography'
  },
  {
    id: 'shadows',
    title: 'Shadows',
    icon: ShadowIcon,
    to: '/utils/shadows'
  },
  {
    id: 'colors',
    title: 'Colors',
    icon: PaletteIcon,
    to: '/utils/colors'
  },

  {
    title: 'Icons',
    icon: WindmillIcon,
    to: '/forms/radio',
    children: [
      {
        id: 'tablericon',
        title: 'Tabler Icons',
        icon: CircleIcon,
        to: 'https://tabler.io/icons',
        type: 'external'
      },
      {
        id: 'materialicon',
        title: 'Material Icons',
        icon: CircleIcon,
        to: 'https://pictogrammers.com/library/mdi/',
        type: 'external'
      }
    ]
  },
  {
    id: 'animation',
    title: 'Animation',
    icon: BrandFramerIcon,
    to: '/utils/animation'
  },
  {
    id: 'grid',
    title: 'Grid',
    icon: LayoutGridAddIcon,
    to: '/utils/grid'
  },
  { divider: true },
  { header: 'Others' },
  {
    title: 'Multilevel',
    icon: MenuIcon,
    children: [
      {
        id: 'level1',
        title: 'Level 1',
        icon: CircleIcon
      },
      {
        title: 'Level 1',
        icon: CircleIcon,
        children: [
          {
            id: 'level2',
            title: 'Level 2',
            icon: CircleIcon
          },
          {
            title: 'Level 2',
            icon: CircleIcon,
            children: [
              {
                id: 'level3',
                title: 'Level 3',
                icon: CircleIcon
              }
            ]
          }
        ]
      }
    ]
  },
  {
    id: 'disabledmenu',
    title: 'Disabled Menu',
    icon: CircleOffIcon,
    disabled: true
  },
  {
    title: 'Avatar',
    icon: BrandGravatarIcon,
    chip: 'coded',
    chipColor: 'primary',
    chipIcon: '$accountCircle'
  },
  {
    title: 'Sub Caption',
    icon: BoxMultipleIcon,
    subCaption: 'caption title'
  },
  { divider: true },
  {
    id: 'sample',
    title: 'Sample Page',
    icon: BrandChromeIcon,
    to: '/starter'
  },
  {
    id: 'documentation',
    title: 'Documentation',
    icon: HelpIcon,
    to: 'https://codedthemes.gitbook.io/berry-vuetify/',
    type: 'external'
  },
  {
    id: 'roadmap',
    title: 'Road Map',
    icon: SitemapIcon,
    to: 'https://codedthemes.gitbook.io/berry-vuetify/roadmap',
    type: 'external'
  }
];

export default sidebarItem;
