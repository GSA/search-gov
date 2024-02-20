import React, { useContext } from 'react';
import styled from 'styled-components';
import Moment from 'react-moment';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { StyleContext } from '../../../contexts/StyleContext';
import { FontsAndColors } from '../../SearchResultsLayout';

interface RssNewsProps {
  newsLabel: string;
  news?: {
    title: string;
    link: string;
    description: string;
    publishedAt: string;
  }[];
}

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  .news-title-wrapper-label {
    color: ${(props) => props.styles.sectionTitleColor};
  }
`;

export const RssNews = ({ newsLabel, news=[] }: RssNewsProps) => {
  const styles = useContext(StyleContext);

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
                  <Grid row gap="md">
                    <Grid col={true} className='result-meta-data'>
                      <span className='published-date'>
                        <Moment fromNow>{newsItem.publishedAt}</Moment>
                      </span>
                      <div className='result-title'>
                        
                        <h2 className='result-title-label'>
                          <a href={newsItem.link} className='result-title-link'>
                            {parse(newsItem.title)}
                          </a>
                        </h2> 
                        
                        {/* <a href={newsItem.link} className='result-title-link'>
                          <h2 className='result-title-label'>
                            {parse(newsItem.title)}
                          </h2>
                        </a> */}
                      </div>
                      <div className='result-desc'>
                        <p>{parse(newsItem.description)}</p>
                        <div className='result-url-text'>{newsItem.link}</div>
                      </div>
                    </Grid>
                  </Grid>
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
