import React from 'react';
import { Grid, Alert as UswdsAlert } from '@trussworks/react-uswds';

import './Alert.css';

export const Alert = () => {
  return (
    <Grid row className='alert-wrapper'>
      <Grid tablet={{ col: true }}>
        <UswdsAlert type="info" heading="Attention" headingLevel="h4">
          We are launching a new ssa.gov. If your search does not return the content you expected, please check back soon for updated results. You may also <a className="usa-link" href="">contact our Webmaster for assistance</a>.
        </UswdsAlert>
      </Grid>
    </Grid>
  );
};
