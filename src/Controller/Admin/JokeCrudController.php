<?php

namespace App\Controller\Admin;

use App\Entity\Joke;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\Field;
use EasyCorp\Bundle\EasyAdminBundle\Field\AssociationField;

class JokeCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Joke::class;
    }


    public function configureFields(string $pageName): iterable
    {
        return [
            Field::new('content'),
            Field::new('answer'),
            AssociationField::new('author'),
        ];
    }
}
