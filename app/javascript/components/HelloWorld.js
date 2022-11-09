import React, { useState } from "react"
import PropTypes from "prop-types"

import { GovBanner, Header, Title, NavMenuButton, ExtendedNav, NavDropDownButton, Menu, Search, GridContainer, Grid } from '@trussworks/react-uswds';
// import 'uswds.css';
import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

//import '../../../node_modules/@trussworks/react-uswds/lib/uswds.css';

class HelloWorld extends React.Component {
  render () {
    const testMenuItems = [
      <a href="#linkOne" key="one">
        Privacy policy
      </a>,
      <a href="#linkTwo" key="two">
        Latest updates
      </a>,
    ];

    const testItemsMenu = [
      <>
        <NavDropDownButton
          onToggle={() => {}}
          menuId="testDropDownOne"
          isOpen={false}
          label="Section"
          isCurrent={true}
        />
        <Menu
          key="one"
          items={testMenuItems}
          isOpen={false}
          id="testDropDownOne"
        />
      </>,
      <a href="#two" key="two" className="usa-nav__link">
        <span>Link</span>
      </a>,
      <a href="#three" key="three" className="usa-nav__link">
        <span>Link</span>
      </a>,
    ];
    return (
      <React.Fragment>
        <GovBanner aria-label="Official government website" />
        <Header extended={true}>
        <div className="usa-navbar">
          <Title>Search.gov</Title>
          <NavMenuButton onClick={() => {}} label="Menu" />
        </div>
        <ExtendedNav
          primaryItems={testItemsMenu}
          secondaryItems={testMenuItems}
          mobileExpanded={false}
          onToggleMobileNav={() => {}}>
        </ExtendedNav>
      </Header>
      <br />
      <GridContainer>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <Search
              placeholder="(Optional) Placeholder Text"
          size="small"
          onSubmit={() => {}}
        /></Grid>
        </Grid>
      </GridContainer>
      <GridContainer>
    <Grid row>
      <Grid col></Grid>
    </Grid>
    <Grid row>
      <Grid col={4}><ExtendedNav
          primaryItems={[
            <a href="#two" key="two" className="usa-nav__link">
              <span>Everything</span>
            </a>,
            <a href="#three" key="three" className="usa-nav__link">
              <span>News</span>
            </a>,
            <a href="#three" key="three" className="usa-nav__link">
            <span>Images</span>
          </a>,
            <a href="#three" key="three" className="usa-nav__link">
            <span>Videos</span>
          </a>,
          ]}
          secondaryItems={[]}
          mobileExpanded={false}
          onToggleMobileNav={() => {}}>
        </ExtendedNav></Grid>
    </Grid>
    </GridContainer>
        Greeting: {this.props.greeting}
      </React.Fragment>
    );
  }
}

HelloWorld.propTypes = {
  greeting: PropTypes.string
};
export default HelloWorld
