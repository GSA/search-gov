import React from 'react';
import { GridContainer } from '@trussworks/react-uswds';
import { I18n } from 'i18n-js';

import type { PageData } from './SearchResultsLayout';
import { Footer } from './Footer/Footer';
import { Header } from './Header';
import { LanguageContext } from '../contexts/LanguageContext';
import { StyleContext, styles } from '../contexts/StyleContext';

import './SearchResultsLayout.css';
import './ErrorPage.css';

interface ErrorPageProps {
  title: string;
  paragraphs: string[];
  page: PageData;
  translations: object;
  language: { code: string; rtl: boolean };
}

const ErrorPage = ({ title, paragraphs, page, translations, language }: ErrorPageProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = language.code;

  return (
    <StyleContext.Provider value={styles}>
      <LanguageContext.Provider value={i18n}>
        <div className="serp-error-page-wrapper">
          <Header page={page} isBasic />
          <main id="main-content" className="usa-section serp-result-wrapper serp-error-page">
            <GridContainer>
              <div className="serp-error-content">
                <h1>{title}</h1>
                {paragraphs.map((paragraph) => (
                  <p key={paragraph} dangerouslySetInnerHTML={{ __html: paragraph }} />
                ))}
              </div>
            </GridContainer>
          </main>
          <Footer />
        </div>
      </LanguageContext.Provider>
    </StyleContext.Provider>
  );
};

export default ErrorPage;
