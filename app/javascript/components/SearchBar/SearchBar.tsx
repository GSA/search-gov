import React from 'react';
import { ExtendedNav, Search, GridContainer, Grid } from '@trussworks/react-uswds';
interface SearchBarProps {
  results: {}[]
}

export const SearchBar = (props: SearchBarProps) => {
  return (
    <div id="serp-search-bar-wrapper">
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
        {props.results.length === 0 &&
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
    </div>
  );
}
