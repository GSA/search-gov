import React, { useState, useEffect, useContext, ReactNode } from 'react';
import { GridContainer, Header, PrimaryNav } from '@trussworks/react-uswds';
import { NavigationLink } from '../SearchResultsLayout';
import { LanguageContext } from '../../contexts/LanguageContext';
import { DropDownMenu } from './DropDownMenu';
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
}

export const VerticalNav = ({ relatedSites = [], navigationLinks = [] }: VerticalNavProps) => {
  const i18n = useContext(LanguageContext);
  const [navItems, setNavItems] = useState<ReactNode[]>([]);
  const [navItemsCount, setNavItemsCount] = useState(0);

  const moreTextWidth = getTextWidth(i18n.t('showMore'));
  const relatedTextWidth = getTextWidth(i18n.t('relatedSearches'));

  const itemToAddWidth = () => currentNavItemWidth() + (isLastItem() ? moreTextWidth : relatedTextWidth) + 100;
  const currentNavItemWidth = () => getTextWidth(navigationLinks[navItemsCount].label) + 100;
  const isLastItem = () => navItemsCount === navigationLinks.length - 1;

  useEffect(() => {
    if ((navItemsCount < navigationLinks.length) && isThereEnoughSpace(itemToAddWidth())) {
      setNavItems([...navItems, buildLink(navigationLinks[navItemsCount], navItemsCount)]);

      setNavItemsCount(navItemsCount + 1);
    } else {
      let items = navigationLinks.slice(navItemsCount).map(buildLink);

      if (items.length) {
        if (relatedSites.length) {
          items.push(<><hr /><i className="text-base-light">{i18n.t('relatedSearches')}</i></>);
          items = items.concat(relatedSites.map(({ link, label }, index) => <a href={link} key={index + items.length}>{label}</a>));
        }

        setNavItems([...navItems, <DropDownMenu key={navItemsCount} label='showMore' items={items} />]);
      } else {
        if (relatedSites.length) {
          items = relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>);

          setNavItems([...navItems, <DropDownMenu key={navItemsCount} label='relatedSearches' items={items} />]);
        }
      }
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
