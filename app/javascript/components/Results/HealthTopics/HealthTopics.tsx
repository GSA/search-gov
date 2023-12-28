import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { StyleContext } from '../../../contexts/StyleContext';
import parse from 'html-react-parser';

import medlineEn from 'legacy/medline.en.png';
import medlineEs from 'legacy/medline.es.png';

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

const StyledWrapper = styled.div.attrs<{ styles: { healthBenefitsHeaderBackgroundColor: string }; }>((props) => ({
  styles: props.styles
}))`
  .health-topic-title {
    background: ${(props) => props.styles.healthBenefitsHeaderBackgroundColor};
  }
`;

const medlineImgSrc = (locale: string) => {
  if (locale === 'en') {
    return medlineEn;
  }

  if (locale === 'es') {
    return medlineEs;
  }
};

export const HealthTopics = ({ description, title, url, relatedTopics=[], studiesAndTrials=[] }: HealthTopicProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);

  return (
    <div className='search-item-wrapper'>
      <StyledWrapper styles={styles}>
        <GridContainer className="health-topic-wrapper">
          <Grid row gap="md">
            <Grid col={true}>
              <GridContainer className='health-topic-title'>
                <a href={url}>{parse(title)}</a>
                <a href={i18n.t('searches.medTopic.homepageUrl')} aria-label="MedlinePlus">
                  <span className='health-med-topic-title'>MedlinePlus</span>
                  <span className='health-med-topic-image'>
                    <img src={medlineImgSrc(i18n.locale)} />
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
      </StyledWrapper>
    </div>
  );
};
