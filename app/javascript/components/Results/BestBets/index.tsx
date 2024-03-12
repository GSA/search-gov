import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { StyleContext } from '../../../contexts/StyleContext';

import { TextBestBet } from './TextBestBet';
import { GraphicsBestBet } from './GraphicsBestBet';

interface BestBetsProps {
  affiliate: string;
  recommendedBy: string;
  vertical: string;
  textBestBets?: {
    title: string;
    url: string;
    description: string;
  }[];
  graphicsBestBet?: {
    title: string;
    titleUrl?: string;
    imageUrl?: string;
    imageAltText?: string;
    links?: {
      title: string;
      url: string;
    }[];
  };
  query: string;
}

const StyledWrapper = styled.div.attrs<{ styles: { bestBetBackgroundColor: string; sectionTitleColor: string; resultUrlColor: string; resultDescriptionColor: string; }; }>((props) => ({
  styles: props.styles
}))`
  .results-best-bets-wrapper > .grid-row > .grid-col {
    background: ${(props) => props.styles.bestBetBackgroundColor};
  }
  .best-bets-title {
    color: ${(props) => props.styles.sectionTitleColor};
  }
  .result-desc > p {
    color: ${(props) => props.styles.resultDescriptionColor} !important;
  }
  .result-url-text{
    color: ${(props) => props.styles.resultUrlColor} !important;
  }
`;

export const BestBets = ({ affiliate, recommendedBy, vertical, textBestBets = [], graphicsBestBet, query }: BestBetsProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);

  return (
    <>
      {(textBestBets?.length > 0 || graphicsBestBet) && (
        <StyledWrapper styles={styles}>
          <GridContainer className="results-best-bets-wrapper">
            <Grid row gap="md" id="best-bets">
              <Grid col={true}>
                <GridContainer className='best-bets-title'>
                  {i18n.t('recommended')} {i18n.t('searches.by')} {recommendedBy}
                </GridContainer>
                {textBestBets?.map((textBestBet, index) => {
                  return (
                    <React.Fragment key={index}>
                      <TextBestBet
                        {...textBestBet}
                        affiliate={affiliate}
                        position={index+1}
                        query={query}
                        vertical={vertical}
                      />
                    </React.Fragment>
                  );
                })}
                {graphicsBestBet && (
                  <GraphicsBestBet
                    {...graphicsBestBet}
                    affiliate={affiliate}
                    query={query}
                    vertical={vertical}
                  />
                )}
              </Grid>
            </Grid>
          </GridContainer>
        </StyledWrapper>
      )}
    </>
  );
};
