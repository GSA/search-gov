import React, { useContext } from 'react';
import styled from 'styled-components';
import Moment from 'react-moment';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { StyleContext } from '../../../contexts/StyleContext';
import { FontsAndColors } from '../../SearchResultsLayout';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from '../ResultGrid/ResultGridWrapper';
import ResultTitle from '../ResultGrid/ResultTitle';

interface RssNewsProps {
  affiliate: string;
  newsLabel: string;
  news?: {
    title: string;
    link: string;
    description: string;
    publishedAt: string;
  }[];
  query: string;
  vertical: string;
}

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  .news-title-wrapper-label {
    color: ${(props) => props.styles.sectionTitleColor};
  }
`;

export const RssNews = ({ affiliate, newsLabel, news=[], query, vertical }: RssNewsProps) => {
  const styles = useContext(StyleContext);

  const module = (() => {
    return moduleCode.rssFeeds;
  })();

  return (
    <>
      {news?.length > 0 && (
        <StyledWrapper styles={styles}>
          <div className='search-item-wrapper search-news-item-wrapper'>
            <GridContainer className='news-title-wrapper'>
              <Grid row gap="md">
                <h2 className='news-title-wrapper-label'>
                  {newsLabel}
                </h2>
              </Grid>
            </GridContainer>
            
            {news?.map((newsItem, index) => {
              return (
                <GridContainer className='result search-result-item' key={index}>
                  <ResultGridWrapper
                    url={newsItem.link}
                    clickTracking={() => clickTracking(affiliate, module, query, index+1, newsItem.link, vertical)}>
                    <Grid col={true} className='result-meta-data'>
                      <span className='published-date'>
                        <Moment fromNow>{newsItem.publishedAt}</Moment>
                      </span>
                      <div className='result-title'>
                        <h2 className='result-title-label'>
                          <ResultTitle 
                            url={newsItem.link}
                            className='result-title-link'
                            clickTracking={() => clickTracking(affiliate, module, query, index+1, newsItem.link, vertical)}>
                            {parse(newsItem.title)}
                          </ResultTitle>
                        </h2> 
                      </div>
                      <div className='result-desc'>
                        <p>{parse(newsItem.description)}</p>
                        <div className='result-url-text'>{newsItem.link}</div>
                      </div>
                    </Grid>
                  </ResultGridWrapper>
                  <Grid row className="row-mobile-divider"></Grid>
                </GridContainer>
              );
            })}
            <GridContainer className='result-divider'>
              <Grid row gap="md">
              </Grid>
            </GridContainer>
          </div>
        </StyledWrapper>
      )}
    </>
  );
};
