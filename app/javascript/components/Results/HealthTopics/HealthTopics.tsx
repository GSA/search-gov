import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import ResultTitle from '../ResultGrid/ResultTitle';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';

import { LanguageContext } from '../../../contexts/LanguageContext';
import { StyleContext } from '../../../contexts/StyleContext';
import { FontsAndColors } from '../../SearchResultsLayout';

import './HealthTopics.css';

import medlineEn from 'legacy/medline.en.png';
import medlineEs from 'legacy/medline.es.png';

interface HealthTopicProps {
  affiliate: string;
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
  query: string;
  vertical: string;
}

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors }>((props) => ({
  styles: props.styles
}))`
  .health-topic-title {
    background: ${(props) => props.styles.healthBenefitsHeaderBackgroundColor};
  }
`;

export const HealthTopics = ({ description, title, url, relatedTopics=[], studiesAndTrials=[], query, affiliate, vertical }: HealthTopicProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);
  const relatedTopicsCount = relatedTopics.length;

  return (
    <div className='search-item-wrapper'>
      <StyledWrapper styles={styles}>
        <GridContainer className="health-topic-wrapper">
          <Grid row gap="md">
            <Grid col={true}>
              <GridContainer className='health-topic-title'>
                <ResultTitle
                  url={url} 
                  clickTracking={() => clickTracking(affiliate, moduleCode.healthTopics, query, 1, url, vertical)} >
                  {parse(title)}
                </ResultTitle>
                <a href={i18n.t('searches.medTopic.homepageUrl')} aria-label="MedlinePlus">
                  <span className='health-med-topic-title'>MedlinePlus</span>
                  <span className='health-med-topic-image'>
                    <img src={i18n.locale === 'es' ? medlineEs : medlineEn} alt='Medline' />
                  </span>
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
                            <ResultTitle
                              url={relatedTopic.url}
                              key={count}
                              className='usa-link'
                              clickTracking={() => clickTracking(affiliate, moduleCode.healthTopics, query, count+2, relatedTopic.url, vertical)} >
                              {parse(relatedTopic.title)}
                            </ResultTitle>
                          ])}
                        </div>
                      )}

                      {studiesAndTrials.length > 0 && (
                        <div className='clinical-studies'>Open clinical studies and trials: &nbsp;
                          {studiesAndTrials.map((studiesAndTrial, count) => [count > 0 && ', ',
                            <ResultTitle
                              url={studiesAndTrial.url}
                              key={count}
                              className='usa-link'
                              clickTracking={() => clickTracking(affiliate, moduleCode.healthTopics, query, relatedTopicsCount + 2, studiesAndTrial.url, vertical)} >
                              {parse(studiesAndTrial.title)}
                            </ResultTitle>
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
      </StyledWrapper>
    </div>
  );
};
