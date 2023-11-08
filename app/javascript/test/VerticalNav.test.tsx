import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';

import * as VNav from '../components/VerticalNav/VerticalNav';
import { LanguageContext } from '../contexts/LanguageContext';

jest.mock('i18n-js', () => jest.requireActual('i18n-js/dist/require/index'));

const locale = {
  en: {
    searches: { relatedSites: 'View Topic' },
    showMore: 'More'
  }
};

const i18n = new I18n(locale);

describe('VerticalNav', () => {
  it('there is no menu without space', () => {
    const navigationLinks = [{ label: 'all', active: true, url: 'http://search.gov', facet: 'Default' }];

    render(
      <LanguageContext.Provider value={i18n} >
        <VNav.VerticalNav navigationLinks={navigationLinks} />
      </LanguageContext.Provider>
    );

    const all = screen.queryByText(/all/i);
    expect(all).not.toBeInTheDocument();
  });

  describe('when screen resizes', () => {
    beforeEach(() => {
      jest.useFakeTimers();
      jest.spyOn(global, 'setTimeout');
    });

    it('rearranges tabs', () => {
      const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
      const navigationLinks = [{ label: 'all', active: true, url: 'http://search.gov', facet: 'Default' }];

      render(
        <LanguageContext.Provider value={i18n} >
          <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );

      fireEvent(window, new Event('resize'));

      expect(setTimeout).toHaveBeenCalled();
    });
  });

  describe('when all tabs fit', () => {
    beforeEach(() => {
      jest.spyOn(VNav, 'isThereEnoughSpace').mockReturnValue(true);
    });

    it('shows related site label on menu when there is only one related site', () => {
      const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
      const navigationLinks = [{ label: 'all', active: true, url: 'http://search.gov', facet: 'Defaut' }];

      render(
        <LanguageContext.Provider value={i18n} >
          <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );

      const all = screen.getByText(/all/i);
      expect(all).toBeInTheDocument();

      const moreLink = screen.getByText(/Related Site 1/i);
      expect(moreLink).toBeInTheDocument();
    });

    it('shows more dropdown when there is multiple related sites', () => {
      const relatedSites = [
        { label: 'Site 1', link: 'one.com' },
        { label: 'Site 2', link: 'two.com' }
      ];

      const navigationLinks = [{ label: 'all', active: true, url: 'http://search.gov', facet: 'Default' }];

      render(
        <LanguageContext.Provider value={i18n} >
          <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );

      const all = screen.getByText(/all/i);
      expect(all).toBeInTheDocument();

      const viewTopic = screen.getByText(/View Topic/i);
      fireEvent.click(viewTopic);

      const one = screen.getByText(/Site 1/i);
      const two = screen.getByText(/Site 2/i);

      expect(one).toBeInTheDocument();
      expect(two).toBeInTheDocument();
    });
  });

  describe('when not all tabs fit', () => {
    beforeEach(() => {
      jest.spyOn(VNav, 'isThereEnoughSpace').mockReturnValueOnce(true).mockReturnValue(false);
    });

    describe('when there is one related site', () => {
      it('shows related site label on menu when there is one related site', () => {
        const navigationLinks = [{ label: 'all', active: true, url: 'http://search.gov', facet: 'Default' }];
        const relatedSites = [{ label: 'Site 1', link: 'one.com' }];

        render(
          <LanguageContext.Provider value={i18n} >
            <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
          </LanguageContext.Provider>
        );

        const all = screen.getByText(/all/i);
        expect(all).toBeInTheDocument();

        const moreLink = screen.getByText(/More/i);
        fireEvent.click(moreLink);

        const siteOne = screen.getByText(/Site 1/i);

        expect(siteOne).toBeInTheDocument();
      });
    });

    describe('when there is multiple related sites', () => {
      it('shows related site label on menu', () => {
        const navigationLinks = [
          { label: 'all',  active: true, url: 'http://search.gov', facet: 'Default' },
          { label: 'none', active: true, url: 'http://none.gov', facet: 'RSS' }
        ];

        const relatedSites = [
          { label: 'Site 1', link: 'one.com' },
          { label: 'Site 2', link: 'two.com' }
        ];

        render(
          <LanguageContext.Provider value={i18n} >
            <VNav.VerticalNav navigationLinks={navigationLinks} relatedSites={relatedSites} />
          </LanguageContext.Provider>
        );

        const all = screen.getByText(/all/i);
        expect(all).toBeInTheDocument();

        const moreLink = screen.getByText(/More/i);
        fireEvent.click(moreLink);

        const viewTopic = screen.getByText(/View Topic/i);
        const siteOne  = screen.getByText(/Site 1/i);
        const siteTwo  = screen.getByText(/Site 2/i);

        expect(viewTopic).toBeInTheDocument();
        expect(siteOne).toBeInTheDocument();
        expect(siteTwo).toBeInTheDocument();
      });
    });
  });

  describe('when active link do not fit in navigation', () => {
    it('moves acive link into a visible stop', () => {
      jest.spyOn(VNav, 'isThereEnoughSpace').
        mockReturnValueOnce(true).
        mockReturnValueOnce(false).
        mockReturnValueOnce(true).
        mockReturnValueOnce(false);

      const relatedSites = [{ label: 'Site 1', link: 'one.com' }];
      const navigationLinks = [
        { label: 'all', active: false, url: 'http://search.gov', facet: 'Default' },
        { label: 'one', active: true,  url: 'http://one.gov', facet: 'YouTube' }
      ];

      render(
        <LanguageContext.Provider value={i18n} >
          <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );
    });
  });
});
