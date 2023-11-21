import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';
interface HealthTopicProps {
  description: string;
  title: string;
  url: string;
  relatedTopics?: {
    title: string;
    url: string;
  }[];
  studiesAndTrials?: {
    title: string;
    url: string;
  }[];
}

export const HealthTopics = ({ description, title, url, relatedTopics=[], studiesAndTrials=[] }: HealthTopicProps) => {
  const i18n = useContext(LanguageContext);
  
  return (
    <div className='search-item-wrapper'>
      <GridContainer className="health-topic-wrapper">
        <Grid row gap="md">
          <Grid col={true}>
            <GridContainer className='health-topic-title'>
              <a href={url}>{parse(title)}</a>
              <a href={i18n.t('searches.medTopic.homepageUrl')} className={`logo-${i18n.locale}`} aria-label="MedlinePlus">
                <span className='health-med-topic-title'>MedlinePlus</span>
                <span className='health-med-topic-image'></span>
              </a>
            </GridContainer>
            <GridContainer className='health-topic-data'>
              <Grid row gap="md">
                <Grid col={true} className='health-topic-meta-data'>
                  <div className='health-topic-desc'>
                    <p>{parse(description)}</p>

                    {relatedTopics.length > 0 && (
                      <div className='related-topics'>{i18n.t('searches.medTopic.relatedTopics')}: &nbsp;
                        {relatedTopics.map((relatedTopic, count) => [count > 0 && ', ',
                          <a className="usa-link" href={relatedTopic.url} key={count}>{parse(relatedTopic.title)}</a>
                        ])}
                      </div>
                    )}

                    {studiesAndTrials.length > 0 && (
                      <div className='clinical-studies'>Open clinical studies and trials: &nbsp;
                        {studiesAndTrials.map((studiesAndTrial, count) => [count > 0 && ', ',
                          <a className="usa-link" href={studiesAndTrial.url} key={count}>{parse(studiesAndTrial.title)}</a>
                        ])}
                      </div>
                    )}
                  </div>
                </Grid>
              </Grid>
            </GridContainer>
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
