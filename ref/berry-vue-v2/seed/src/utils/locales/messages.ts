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
      carousel: {
        ariaLabel: {
          delimiter: 'Carousel slide {0} of {1}'
        }
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
      carousel: {
        ariaLabel: {
          delimiter: 'Diapozitiv carusel {0} din {1}'
        }
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
      carousel: {
        ariaLabel: {
          delimiter: 'Diapositive de carrousel {0} sur {1}'
        }
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
      carousel: {
        ariaLabel: {
          delimiter: '轮播幻灯片 {0} / {1}'
        }
      }
    }
  }
};
