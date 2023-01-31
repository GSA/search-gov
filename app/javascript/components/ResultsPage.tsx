import * as React from 'react';

import { GovBanner, Header, Title, NavMenuButton, ExtendedNav, NavDropDownButton, Menu, Search, GridContainer, Grid } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

interface ResultsPageProps {
  results: any;
  params: any;
  vertical: any;
};

interface Nothing {};

class ResultsPage extends React.Component<ResultsPageProps, Nothing> {
  render () {
    const testMenuItems = [
      <a href="#" key="one">
        Privacy policy
      </a>,
      <a href="#" key="two">
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

        <GridContainer>
          <Grid row>
            <Grid tablet={{ col: true }}>
              <Search
                placeholder="Please enter a search term."
                size="small"
                onSubmit={() => {}}
              />
            </Grid>
          </Grid>
          {this.props.results.length === 0 &&
            <Grid row>
              <Grid tablet={{ col: true }}><h4>Please enter a search term in the box above.</h4></Grid>
          </Grid>}
        </GridContainer>

        <GridContainer>
          <Grid row>
            <Grid col></Grid>
          </Grid>
          <Grid row>
            <Grid col={4}>
              <ExtendedNav
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
                onToggleMobileNav={() => {}}
              >
              </ExtendedNav>
            </Grid>
          </Grid>
        </GridContainer>

        <div id='results'>
          {this.props.results.map((result, index) => {
            return (
              <div className='result' key={index}>
                <GridContainer>
                  <Grid row>
                    <Grid tablet={{ col: true }}><a href= "#" ><h4>{result['title']}</h4></a></Grid>
                  </Grid>
                  <Grid row>
                    <Grid tablet={{ col: true }}><a href= "#">{result['unescapedUrl']}</a></Grid>
                  </Grid>
                  {this.props.vertical === 'image' && <Grid row>
                    <Grid tablet={{ col: true }}><img src={result['thumbnail']['url']} /></Grid>
                  </Grid>}
                  <Grid row>
                    <Grid tablet={{ col: true }}><p>{result['content']}</p></Grid>
                  </Grid>
                </GridContainer>
              </div>
              )
            }
          )}
        </div>
      </React.Fragment>
    );
  }
}

export default ResultsPage;
