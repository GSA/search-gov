import React, { useState, ReactNode, createRef, useEffect, RefObject, useId, useContext } from 'react';
import styled from 'styled-components';
import { NavDropDownButton, Menu } from '@trussworks/react-uswds';
import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors } from '../SearchResultsLayout';

const StyledDiv = styled('div').attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  .usa-nav__submenu{
    background-color: ${(props) => props.styles.searchTabNavigationLinkColor} !important;
  }
`;

interface DropDownMenuProps {
  label: string,
  items: ReactNode[]
}

export const DropDownMenu = ({ label, items }: DropDownMenuProps) => {
  const id      = useId();
  const styles  = useContext(StyleContext);
  const [openMore, setOpenMore] = useState(false);
  const btnRef: RefObject<HTMLDivElement> = createRef();

  useEffect(() => {
    const closeDropDown = (event: Event) => {
      if (btnRef.current && !btnRef.current.contains(event.target as HTMLDivElement)) {
        setOpenMore(false);
      }
    };

    document.body.addEventListener('click', closeDropDown);

    return () => document.body.removeEventListener('click', closeDropDown);
  });

  return (
    <StyledDiv ref={btnRef} styles={styles}>
      <NavDropDownButton
        menuId={id}
        onToggle={() => setOpenMore((prev) => !prev)}
        isOpen={openMore}
        label={label}
      />
      <Menu items={items} isOpen={openMore} id={id} />
    </StyledDiv>
  );
};
