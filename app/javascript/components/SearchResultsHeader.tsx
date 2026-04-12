import React from 'react';
import { I18n } from 'i18n-js';

import { Header } from './Header';
import { LanguageContext } from '../contexts/LanguageContext';
import { StyleContext, styles } from '../contexts/StyleContext';
import { FontsAndColors, Language, PageData } from './SearchResultsLayout';

interface SearchResultsHeaderProps {
  page: PageData;
  extendedHeader: boolean;
  translations: Record<string, unknown>;
  language?: Language;
  fontsAndColors?: FontsAndColors;
  primaryHeaderLinks?: {
    title: string;
    url: string;
  }[];
  secondaryHeaderLinks?: {
    title: string;
    url: string;
  }[];
}

const SearchResultsHeader = ({
  page,
  extendedHeader,
  translations,
  language = { code: 'en', rtl: false },
  fontsAndColors,
  primaryHeaderLinks,
  secondaryHeaderLinks
}: SearchResultsHeaderProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = language.code;

  return (
    <LanguageContext.Provider value={i18n}>
      <StyleContext.Provider value={fontsAndColors || styles}>
        <Header
          page={page}
          isBasic={!extendedHeader}
          primaryHeaderLinks={primaryHeaderLinks}
          secondaryHeaderLinks={secondaryHeaderLinks}
        />
      </StyleContext.Provider>
    </LanguageContext.Provider>
  );
};

export default SearchResultsHeader;
