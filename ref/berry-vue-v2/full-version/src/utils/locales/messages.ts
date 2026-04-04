import en from './en.json';
import fr from './fr.json';
import ro from './ro.json';
import zhHans from './zhHans.json';

export const messages = {
  en: {
    ...en,
    $vuetify: {
      ...en,
      open: 'Open',
      close: 'Close',
      input: {
        clear: 'Clear',
        appendAction: 'Append action',
        prependAction: 'Prepend action',
        otp: 'Enter character {0}'
      },
      fileInput: {
        counter: '{0} files',
        counterSize: '{0} files'
      },
      confirmEdit: {
        ok: 'OK',
        cancel: 'Cancel'
      },
      carousel: {
        ariaLabel: {
          delimiter: 'Carousel slide {0} of {1}'
        }
      },
      rating: {
        ariaLabel: {
          item: 'Rating item {0} of {1}'
        }
      },
      dataTable: {
        noDataText: 'No data available',
        itemsPerPageText: 'Items per page:',
        sortBy: 'Sort by'
      },
      noDataText: 'No data available',
      dataFooter: {
        firstPage: 'First page',
        prevPage: 'Previous page',
        nextPage: 'Next page',
        lastPage: 'Last page',
        itemsPerPageText: 'Items per page:',
        itemsPerPageAll: 'All',
        pageText: '{0}-{1} of {2}'
      },
      dataIterator: {
        loadingText: 'Loading items...',
        noDataText: 'No data available'
      },
      pagination: {
        ariaLabel: {
          root: 'Pagination Navigation',
          page: 'Go to page {0}',
          previous: 'Go to previous page',
          next: 'Go to next page',
          currentPage: 'Current page {0}'
        }
      },
      stepper: {
        prev: 'Previous',
        next: 'Next'
      },
      datePicker: {
        ariaLabel: {
          selectDate: 'Select date',
          currentDate: 'Current date',
          nextMonth: 'Next month',
          previousMonth: 'Previous month',
          nextYear: 'Next year',
          previousYear: 'Previous year',
          selectYear: 'Select year',
          selectMonth: 'Select month'
        },
        header: 'Select date',
        title: 'Select date'
      },
      timePicker: {
        am: 'AM',
        pm: 'PM',
        title: 'Select time',
        hour: 'Hour',
        minute: 'Minute',
        second: 'Second'
      },
      fileUpload: {
        title: 'Drop files here or click to upload',
        browse: 'Browse',
        divider: 'or'
      },
      badge: 'Badge',
      loading: 'Loading...',
      calendar: {
        moreEvents: 'and {0} more'
      }
    }
  },
  ro: {
    ...ro,
    $vuetify: {
      ...ro,
      open: 'Deschide',
      close: 'Închide',
      input: {
        clear: 'Șterge',
        appendAction: 'Acțiune anexă',
        prependAction: 'Acțiune prepusă',
        otp: 'Introduceți caracterul {0}'
      },
      fileInput: {
        counter: '{0} fișiere',
        counterSize: '{0} fișiere'
      },
      confirmEdit: {
        ok: 'OK',
        cancel: 'Anulează'
      },
      carousel: {
        ariaLabel: {
          delimiter: 'Diapozitiv carusel {0} din {1}'
        }
      },
      rating: {
        ariaLabel: {
          item: 'Element de evaluare {0} din {1}'
        }
      },
      noDataText: 'Nu există date disponibile',
      dataTable: {
        noDataText: 'Nu există date disponibile',
        itemsPerPageText: 'Elemente pe pagină:',
        sortBy: 'Sortează după'
      },
      dataFooter: {
        firstPage: 'Prima pagină',
        prevPage: 'Pagina anterioară',
        nextPage: 'Pagina următoare',
        lastPage: 'Ultima pagină',
        itemsPerPageText: 'Elemente pe pagină:',
        itemsPerPageAll: 'Toate',
        pageText: '{0}-{1} din {2}'
      },
      dataIterator: {
        loadingText: 'Se încarcă elementele...',
        noDataText: 'Nu există date disponibile'
      },
      pagination: {
        ariaLabel: {
          root: 'Navigare paginare',
          page: 'Mergi la pagina {0}',
          previous: 'Mergi la pagina anterioară',
          next: 'Mergi la pagina următoare',
          currentPage: 'Pagina curentă {0}'
        }
      },
      stepper: {
        prev: 'Anterior',
        next: 'Următor'
      },
      datePicker: {
        ariaLabel: {
          selectDate: 'Selectează data',
          currentDate: 'Data curentă',
          nextMonth: 'Luna următoare',
          previousMonth: 'Luna anterioară',
          nextYear: 'Anul următor',
          previousYear: 'Anul anterior',
          selectYear: 'Selectează anul',
          selectMonth: 'Selectează luna'
        },
        header: 'Selectează data',
        title: 'Selectează data'
      },
      timePicker: {
        am: 'AM',
        pm: 'PM',
        title: 'Selectează ora',
        hour: 'Oră',
        minute: 'Minut',
        second: 'Secundă'
      },
      fileUpload: {
        title: 'Trageți fișierele aici sau faceți clic pentru a încărca',
        browse: 'Răsfoiește',
        divider: 'sau'
      },
      badge: 'Insignă',
      loading: 'Se încarcă...',
      calendar: {
        moreEvents: 'și încă {0}'
      }
    }
  },
  fr: {
    ...fr,
    $vuetify: {
      ...fr,
      open: 'Ouvrir',
      close: 'Fermer',
      input: {
        clear: 'Effacer',
        appendAction: "Action d'ajout",
        prependAction: 'Action de préfixe',
        otp: 'Entrez le caractère {0}'
      },
      fileInput: {
        counter: '{0} fichiers',
        counterSize: '{0} fichiers'
      },
      confirmEdit: {
        ok: 'OK',
        cancel: 'Annuler'
      },
      carousel: {
        ariaLabel: {
          delimiter: 'Diapositive de carrousel {0} sur {1}'
        }
      },
      rating: {
        ariaLabel: {
          item: "Élément d'évaluation {0} sur {1}"
        }
      },
      noDataText: 'Pas de données disponibles',
      dataTable: {
        noDataText: 'Pas de données disponibles',
        itemsPerPageText: 'Articles par page :',
        sortBy: 'Trier par'
      },
      dataFooter: {
        firstPage: 'Première page',
        prevPage: 'Page précédente',
        nextPage: 'Page suivante',
        lastPage: 'Dernière page',
        itemsPerPageText: 'Éléments par page:',
        itemsPerPageAll: 'Tous',
        pageText: '{0}-{1} sur {2}'
      },
      dataIterator: {
        loadingText: 'Chargement des éléments...',
        noDataText: 'Pas de données disponibles'
      },
      pagination: {
        ariaLabel: {
          root: 'Navigation de pagination',
          page: 'Aller à la page {0}',
          previous: 'Aller à la page précédente',
          next: 'Aller à la page suivante',
          currentPage: 'Page actuelle {0}'
        }
      },
      stepper: {
        prev: 'Précédent',
        next: 'Suivant'
      },
      datePicker: {
        ariaLabel: {
          selectDate: 'Sélectionner la date',
          currentDate: 'Date actuelle',
          nextMonth: 'Mois suivant',
          previousMonth: 'Mois précédent',
          nextYear: 'Année suivante',
          previousYear: 'Année précédente',
          selectYear: 'Sélectionner l’année',
          selectMonth: 'Sélectionner le mois'
        },
        header: 'Sélectionner la date',
        title: 'Sélectionner la date'
      },
      timePicker: {
        am: 'AM',
        pm: 'PM',
        title: "Sélectionner l'heure",
        hour: 'Heure',
        minute: 'Minute',
        second: 'Seconde'
      },
      fileUpload: {
        title: 'Déposez les fichiers ici ou cliquez pour télécharger',
        browse: 'Parcourir',
        divider: 'ou'
      },
      badge: 'Badge',
      loading: 'Chargement...',
      calendar: {
        moreEvents: 'et {0} de plus'
      }
    }
  },
  zhHans: {
    ...zhHans,
    $vuetify: {
      ...zhHans,
      open: '打开',
      close: '关闭',
      input: {
        clear: '清除',
        appendAction: '附加操作',
        prependAction: '前置操作',
        otp: '输入字符 {0}'
      },
      fileInput: {
        counter: '{0} 个文件',
        counterSize: '{0} 个文件'
      },
      confirmEdit: {
        ok: '确定',
        cancel: '取消'
      },
      carousel: {
        ariaLabel: {
          delimiter: '轮播幻灯片 {0} / {1}'
        }
      },
      rating: {
        ariaLabel: {
          item: '评分项目 {0} / {1}'
        }
      },
      noDataText: '没有可用数据',
      dataTable: {
        noDataText: '没有可用数据',
        itemsPerPageText: '每页条目数:',
        sortBy: '排序方式'
      },
      dataFooter: {
        firstPage: '首页',
        prevPage: '上一页',
        nextPage: '下一页',
        lastPage: '末页',
        itemsPerPageText: '每页项目数:',
        itemsPerPageAll: '全部',
        pageText: '{0}-{1} 共 {2}'
      },
      dataIterator: {
        loadingText: '正在加载项目...',
        noDataText: '没有可用数据'
      },
      pagination: {
        ariaLabel: {
          root: '分页导航',
          page: '转到第 {0} 页',
          previous: '转到上一页',
          next: '转到下一页',
          currentPage: '当前第 {0} 页'
        }
      },
      stepper: {
        prev: '上一步',
        next: '下一步'
      },
      datePicker: {
        ariaLabel: {
          selectDate: '选择日期',
          currentDate: '当前日期',
          nextMonth: '下个月',
          previousMonth: '上个月',
          nextYear: '下一年',
          previousYear: '上一年',
          selectYear: '选择年份',
          selectMonth: '选择月份'
        },
        header: '选择日期',
        title: '选择日期'
      },
      timePicker: {
        am: '上午',
        pm: '下午',
        title: '选择时间',
        hour: '小时',
        minute: '分钟',
        second: '秒'
      },
      fileUpload: {
        title: '将文件拖放到此处或点击上传',
        browse: '浏览',
        divider: '或'
      },
      badge: '徽章',
      loading: '加载中...',
      calendar: {
        moreEvents: '还有 {0} 个'
      }
    }
  }
};
