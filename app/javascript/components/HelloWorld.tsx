import React from "react";

import { GovBanner, Header, Title, NavMenuButton, ExtendedNav, NavDropDownButton, Menu, Search, GridContainer, Grid } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

interface HelloWorldProps {
  results: any;
  params: any;
};

interface Nothing {};

class HelloWorld extends React.Component<HelloWorldProps, Nothing> {
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
    <GridContainer>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#"><h4>{this.props.results[0]['title']}</h4></a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#">{this.props.results[0]['unescapedUrl']}</a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><p>{this.props.results[0]['content']}</p></Grid>
    </Grid>
  </GridContainer>
  <br></br>
  <GridContainer>
  <Grid row>
      <Grid tablet={{ col: true }}><a href= "#"><h4>{this.props.results[1]['title']}</h4></a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#">{this.props.results[1]['unescapedUrl']}</a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><p>{this.props.results[1]['content']}</p></Grid>
    </Grid>
  </GridContainer>
  <br></br>
  <GridContainer>
  <Grid row>
      <Grid tablet={{ col: true }}><a href= "#"><h4>{this.props.results[2]['title']}</h4></a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#">{this.props.results[2]['unescapedUrl']}</a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><p>{this.props.results[2]['content']}</p></Grid>
    </Grid>
  </GridContainer>
  <br></br>
  <GridContainer>
  <Grid row>
      <Grid tablet={{ col: true }}><a href= "#"><h4>{this.props.results[3]['title']}</h4></a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#">{this.props.results[3]['unescapedUrl']}</a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><p>{this.props.results[3]['content']}</p></Grid>
    </Grid>
  </GridContainer>
  <br></br>
  <GridContainer>
  <Grid row>
      <Grid tablet={{ col: true }}><a href= "#"><h4>{this.props.results[4]['title']}</h4></a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><a href= "#">{this.props.results[4]['unescapedUrl']}</a></Grid>
    </Grid>
    <Grid row>
      <Grid tablet={{ col: true }}><p>{this.props.results[4]['content']}</p></Grid>
    </Grid>
  </GridContainer>
  <a href={`/search?${new URLSearchParams(this.props.params).toString()}`}>{JSON.stringify(this.props.params)}</a>
      </React.Fragment>
    );
  }
}

export default HelloWorld;
