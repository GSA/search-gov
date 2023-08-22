import { createContext } from 'react';
import { I18n } from 'i18n-js';

const i18n = new I18n({});

export const LanguageContext = createContext(i18n);
