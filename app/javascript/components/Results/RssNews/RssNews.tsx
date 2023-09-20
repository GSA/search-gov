import React from 'react';
import Moment from 'react-moment';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
interface RssNewsProps {
  recommendedBy: string;
  news?: {
    title: string;
    link: string;
    description: string;
    publishedAt: string;
  }[];
}

export const RssNews = ({ recommendedBy, news=[] }: RssNewsProps) => {
  return (
    <>
      {news?.length > 0 && (
        <div className='search-item-wrapper search-news-item-wrapper'>
          <GridContainer className='news-title-wrapper'>
            <Grid row gap="md">
              <h2 className='news-title-wrapper-label'>
                News about {recommendedBy}
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
                      <a href={newsItem.link} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {parse(newsItem.title)}
                        </h2>
                      </a>
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
      )}
    </>
  );
};
