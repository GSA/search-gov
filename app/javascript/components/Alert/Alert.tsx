import React from 'react';
import { Grid, Alert as UswdsAlert } from '@trussworks/react-uswds';

import './Alert.css';

interface AlertProps {
  title: string;
  text: string;
}

export const Alert = ({ text, title }: AlertProps) => {
  return (
    <Grid row className='alert-wrapper'>
      <Grid tablet={{ col: true }}>
        <UswdsAlert type="info" heading={title} headingLevel="h4">
          {text}
        </UswdsAlert>
      </Grid>
    </Grid>
  );
};
