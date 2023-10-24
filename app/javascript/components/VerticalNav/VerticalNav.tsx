import React, { useState, useEffect, useContext, ReactNode } from 'react';
import { GridContainer, Header, PrimaryNav } from '@trussworks/react-uswds';

import { DropDownMenu } from './DropDownMenu';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';
import { getTextWidth } from '../../utils';

import './VerticalNav.css';

const buildLink = ({ active, label, href }: NavigationLink, key = 0) => <a href={href} key={key} className={ active && 'usa-current' || '' }>{label}</a>;

export const isThereEnoughSpace = (itemToAddWidth: number) => {
  const container = document.getElementById('tabs-container');

  if (container) {
    const nav = container.getElementsByClassName('usa-nav__primary');

    if (nav && nav[0]) {
      return container.offsetWidth > ((nav[0] as HTMLElement).offsetWidth + itemToAddWidth);
    }
  }
};

interface VerticalNavProps {
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
  relatedSitesDropdownLabel: string;
}

export const VerticalNav = ({ relatedSites = [], navigationLinks = [], relatedSitesDropdownLabel = '' }: VerticalNavProps) => {
  const i18n = useContext(LanguageContext);
  const [navItems, setNavItems] = useState<ReactNode[]>([]);
  const [navItemsCount, setNavItemsCount] = useState(0);

  const moreTextWidth = getTextWidth(i18n.t('showMore'));
  const relatedTextWidth = getTextWidth(i18n.t('relatedSearches'));

  const itemToAddWidth = () => currentNavItemWidth() + (isLastItem() ? moreTextWidth : relatedTextWidth) + 100;
  const currentNavItemWidth = () => getTextWidth(navigationLinks[navItemsCount].label) + 100;
  const isLastItem = () => navItemsCount === navigationLinks.length - 1;

  useEffect(() => {
    if (navItemsCount < navigationLinks.length) {
      if (isThereEnoughSpace(itemToAddWidth()))  {
        setNavItems([...navItems, buildLink(navigationLinks[navItemsCount], navItemsCount)]);

        setNavItemsCount(navItemsCount + 1);
      } else {
        let activeIndex = navigationLinks.findIndex((navLink) => navLink.active);

        if (activeIndex >= navItemsCount) {
          [navigationLinks[activeIndex], navigationLinks[navItemsCount - 1]] = [navigationLinks[navItemsCount - 1], navigationLinks[activeIndex]];

          setNavItems([]);
          setNavItemsCount(0);
        } else {
          let items = navigationLinks.slice(navItemsCount).map(buildLink);

          if (relatedSites.length) {
            items.push(<><hr /><i className="text-base-light">{i18n.t('relatedSearches')}</i></>);
            items = items.concat(relatedSites.map(({ link, label }, index) => <a href={link} key={index + items.length}>{label}</a>));
          }

          setNavItems([...navItems, <DropDownMenu key={navItemsCount} label={i18n.t('showMore')} items={items} />]);
        }
      }
    } else if (relatedSites.length == 1) {
      setNavItems([...navItems, <a href={relatedSites[0].link} >{relatedSites[0].label}</a>]);

    } else if (relatedSites.length) {
      let items = relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>);

      let label = '';

      if (relatedSitesDropdownLabel) {
        label = relatedSitesDropdownLabel;
      } else {
        label = i18n.t('searches.relatedSites');
      }

      setNavItems([...navItems, <DropDownMenu key={navItemsCount} label={label} items={items} />]);
    }
  }, [navItemsCount]);

  return (
    <div className="vertical-nav-wrapper">
      <GridContainer>
        <Header basic={true} className="vertical-wrapper">
          <div className="usa-nav-container" id="tabs-container">
            <PrimaryNav items={navItems} />
          </div>
        </Header>
      </GridContainer>
    </div>
  );
};
