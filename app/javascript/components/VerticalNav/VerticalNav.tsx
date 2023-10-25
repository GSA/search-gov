import React, { useState, useEffect, useContext, ReactNode, useRef } from 'react';
import { GridContainer, Header, PrimaryNav } from '@trussworks/react-uswds';

import { DropDownMenu } from './DropDownMenu';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';
import { getTextWidth, move } from '../../utils';

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
  const i18n             = useContext(LanguageContext);
  const relatedLabel     = useRef(relatedSitesDropdownLabel || i18n.t('searches.relatedSites'));
  const moreTextWidth    = useRef(getTextWidth(i18n.t('showMore')));
  const relatedTextWidth = useRef(getTextWidth(relatedLabel));

  const [navItems, setNavItems]           = useState<ReactNode[]>([]);
  const [navItemsCount, setNavItemsCount] = useState(0);

  const itemToAddWidth      = () => currentNavItemWidth() + (isLastItem() ? moreTextWidth.current : relatedTextWidth.current) + 100;
  const currentNavItemWidth = () => getTextWidth(navigationLinks[navItemsCount].label) + 100;
  const isLastItem          = () => navItemsCount === navigationLinks.length - 1;

  useEffect(() => {
    if (navItemsCount < navigationLinks.length) {
      if (isThereEnoughSpace(itemToAddWidth()))  {
        setNavItems([...navItems, buildLink(navigationLinks[navItemsCount], navItemsCount)]);

        setNavItemsCount(navItemsCount + 1);
      } else {
        const activeIndex = navigationLinks.findIndex((navLink) => navLink.active);

        if (activeIndex >= navItemsCount) {
          move(navigationLinks, activeIndex, navItemsCount - 1);

          setNavItems([]);
          setNavItemsCount(0);
        } else {
          let items = navigationLinks.slice(navItemsCount).map(buildLink);

          if (relatedSites.length) {
            items.push(<><hr /><i className="text-base-light">{relatedLabel.current}</i></>);
            items = items.concat(relatedSites.map(({ link, label }, index) => <a href={link} key={index + items.length}>{label}</a>));
          }

          setNavItems([...navItems, <DropDownMenu key={navItemsCount} label={i18n.t('showMore')} items={items} />]);
        }
      }
    } else if (relatedSites.length === 1) {
      setNavItems([...navItems, <a href={relatedSites[0].link} key={navItemsCount}>{relatedSites[0].label}</a>]);
    } else if (relatedSites.length) {
      const items = relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>);

      setNavItems([...navItems, <DropDownMenu key={navItemsCount} label={relatedLabel.current} items={items} />]);
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
