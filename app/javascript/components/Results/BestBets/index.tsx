import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';

import { TextBestBet } from './TextBestBet';
import { GraphicsBestBet } from './GraphicsBestBet';

interface BestBetsProps {
  recommendedBy: string;
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
  }
}

export const BestBets = ({ recommendedBy, textBestBets = [], graphicsBestBet }: BestBetsProps) => {
  const i18n = useContext(LanguageContext);

  return (
    <>
      {(textBestBets?.length > 0 || graphicsBestBet) && (
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
                    />
                  </React.Fragment>
                );
              })}
              {graphicsBestBet && (
                <GraphicsBestBet
                  {...graphicsBestBet}
                />
              )}
            </Grid>
          </Grid>
        </GridContainer>
      )}
    </>
  );
};
