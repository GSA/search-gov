import React, { useContext, useState, useEffect, ReactNode, useRef } from 'react';
import styled from 'styled-components';
import { GridContainer, Header, PrimaryNav } from '@trussworks/react-uswds';

import { DropDownMenu } from './DropDownMenu';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';
import { getTextWidth, move } from '../../utils';
import { StyleContext } from '../../contexts/StyleContext';

import './VerticalNav.css';

const StyledPrimaryNav = styled(PrimaryNav).attrs<{ styles: { searchTabNavigationLinkColor: string; activeSearchTabNavigationColor: string; }; }>((props) => ({
  styles: props.styles
}))`
  li.usa-nav__primary-item:not(li.usa-nav__submenu-item) > a,
  .usa-nav__primary > .usa-nav__primary-item button[aria-expanded=false] {
    color: ${(props) => props.styles.searchTabNavigationLinkColor} !important;
  }
  .usa-current::after,
  .usa-nav__primary > .usa-nav__primary-item button[aria-expanded=true] {
    background-color: ${(props) => props.styles.searchTabNavigationLinkColor} !important;
  }
  .vertical-wrapper .usa-nav__submenu{
    background-color: ${(props) => props.styles.searchTabNavigationLinkColor} !important;
  }
`;

const buildLink = ({ active, label, url }: NavigationLink, key = 0) => <a href={url} key={key} className={ active && 'usa-current' || '' }>{label}</a>;

export const isThereEnoughSpace = (itemToAddWidth: number) => {
  const container = document.getElementById('tabs-container');

  if (container) {
    const ul = container.getElementsByClassName('usa-nav__primary').item(0);

    return (container.offsetWidth - (ul as HTMLElement).offsetWidth) >= itemToAddWidth;
  }
};

interface VerticalNavProps {
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
  relatedSitesDropdownLabel?: string;
}

export const VerticalNav = ({ relatedSites = [], navigationLinks = [], relatedSitesDropdownLabel = '' }: VerticalNavProps) => {
  const i18n             = useContext(LanguageContext);
  const styles           = useContext(StyleContext);
  const arrowWidth       = 16;
  const padding          = 32;
  const moreItemWidth    = useRef(getTextWidth(i18n.t('showMore')) + padding + arrowWidth);
  const relatedLabel     = useRef(relatedSitesDropdownLabel || i18n.t('searches.relatedSites'));
  const relatedTextWidth = useRef(getTextWidth(relatedLabel.current));
  const resizeTimeout    = useRef<ReturnType<typeof setTimeout>>();

  const [navItems, setNavItems]           = useState<ReactNode[]>([]);
  const [navItemsCount, setNavItemsCount] = useState(0);

  const currentNavItemWidth = () => getTextWidth(navigationLinks[navItemsCount].label) + padding;
  const isLastItem          = () => navItemsCount === navigationLinks.length - 1;
  const itemToAddWidth      = () => currentNavItemWidth() + nextItemWidth();
  const nextItemWidth       = () => isLastItem() ? relatedSitesWidth() : moreItemWidth.current;
  const relatedSitesWidth   = () => relatedSites.length ? relatedTextWidth.current + padding : 0;

  const rearrangeTabs = () => {
    setNavItems([]);
    setNavItemsCount(0);
  };

  const addNavItem = (item: ReactNode) => setNavItems([...navItems, item]);
  const addMoreBtn = () => {
    const activeIndex = navigationLinks.findIndex((navLink) => navLink.active);

    if (activeIndex >= navItemsCount) {
      const position = navItemsCount === activeIndex ? navItemsCount - 1 : navItemsCount;

      move(navigationLinks, activeIndex, position);
      rearrangeTabs();
    } else {
      let items = navigationLinks.slice(navItemsCount).map(buildLink);

      if (relatedSites.length) {
        if (relatedSites.length > 1) {
          items.push(<><hr /><i className="text-base-lightest text-bold">{relatedLabel.current}</i></>);
        }

        items = items.concat(relatedSites.map(({ link, label }, index) => <a href={link} key={index + items.length}>{label}</a>));
      }

      addNavItem(<DropDownMenu key={navItemsCount} label={i18n.t('showMore')} items={items} />);
    }
  };

  useEffect(() => {
    const resizeTabs = () => {
      clearTimeout(resizeTimeout.current);

      resizeTimeout.current = setTimeout(rearrangeTabs, 10);
    };

    window.addEventListener('resize', resizeTabs);
  });

  useEffect(() => {
    if (navItemsCount < navigationLinks.length) {
      if (isThereEnoughSpace(itemToAddWidth()))  {
        addNavItem(buildLink(navigationLinks[navItemsCount], navItemsCount));

        setNavItemsCount(navItemsCount + 1);
      } else {
        addMoreBtn();
      }
    } else {
      if (relatedSites.length === 1) {
        if (isThereEnoughSpace(getTextWidth(relatedSites[0].label) + padding))  {
          addNavItem(<a href={relatedSites[0].link} key={navItemsCount}>{relatedSites[0].label}</a>);
        } else {
          addMoreBtn();
        }
      } else if (relatedSites.length) {
        const items = relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>);

        addNavItem(<DropDownMenu key={navItemsCount} label={relatedLabel.current} items={items} />);
      }
    }
  }, [navItemsCount]);

  return (
    <div className="vertical-nav-wrapper">
      <GridContainer>
        <Header basic={true} className="vertical-wrapper">
          <div className="usa-nav-container" id="tabs-container">
            <StyledPrimaryNav items={navItems} styles={styles} />
          </div>
        </Header>
      </GridContainer>
    </div>
  );
};
