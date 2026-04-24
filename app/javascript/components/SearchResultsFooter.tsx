import React from 'react';
import { I18n } from 'i18n-js';

import { Footer } from './Footer/Footer';
import { LanguageContext } from '../contexts/LanguageContext';
import { StyleContext, styles } from '../contexts/StyleContext';
import { FontsAndColors, Language } from './SearchResultsLayout';

interface SearchResultsFooterProps {
  footerLinks?: {
    title: string;
    url: string;
  }[];
  translations: Record<string, unknown>;
  language?: Language;
  fontsAndColors?: FontsAndColors;
}

const SearchResultsFooter = ({
  footerLinks,
  translations,
  language = { code: 'en', rtl: false },
  fontsAndColors
}: SearchResultsFooterProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = language.code;

  return (
    <LanguageContext.Provider value={i18n}>
      <StyleContext.Provider value={fontsAndColors || styles}>
        <Footer footerLinks={footerLinks} />
      </StyleContext.Provider>
    </LanguageContext.Provider>
  );
};

export default SearchResultsFooter;
