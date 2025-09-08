<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

// Controlleur créé pour éviter l'erreur 404
class HealthController extends AbstractController
{
    #[Route('/', name: 'health_check', methods: ['HEAD', 'GET'])]
    public function __invoke(): Response
    {
        return new Response(null, Response::HTTP_NO_CONTENT);
    }
}
